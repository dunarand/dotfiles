#!/usr/bin/env python3
"""
launch.py — Hyprland Layout Launcher
Reads a layout JSON produced by capture.py and recreates it:

  For each workspace (in order):
    1. Launch each window onto a staging workspace (ws 99) so they never
       land on a real workspace mid-launch and collide with each other.
       Grouped windows within a cell are launched sequentially (wait for
       each before launching the next). Cells across the workspace are also
       launched sequentially so tiling order is deterministic.
    2. Once all windows on the workspace are confirmed, move them to the
       real workspace in matrix order (column 0 row 0 first, then row 1,
       then column 1 row 0, etc.). This gives the compositor a predictable
       tiling sequence.
    3. Verify and correct tiling order using swapwindow.
    4. Resize each slot to its saved dimensions.
    5. Form groups (togglegroup + moveintogroup), verified with retry.

Usage:
    python3 launch.py <layout.json> [--apps <apps.json>] [--timeout 30]
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

STAGING_WS = 99  # scratch workspace; must not be used by the user
POLL_INTERVAL = 0.25  # seconds between hyprctl polls
WINDOW_TIMEOUT = 15.0  # seconds to wait for a single window to appear
GROUP_RETRIES = 5
GROUP_RETRY_DELAY = 0.4
SWAP_SETTLE = 0.15
RESIZE_SETTLE = 0.15


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------


class WindowSpec:
    """One window entry from the layout JSON."""

    def __init__(self, wid: str, data: dict):
        self.wid = wid
        self.wm_class = data["wm_class"]
        self.initial_class = data["initial_class"]
        self.initial_title = data["initial_title"]
        self.width = data["width"]
        self.height = data["height"]
        self.is_group_leader = data.get(
            "is_group_leader"
        )  # None = not in group
        # Filled in after the window appears:
        self.address: str | None = None


class Cell:
    """One cell in the workspace matrix (one tiling slot)."""

    def __init__(self, windows: list[WindowSpec]):
        self.windows = windows  # length > 1 means a group

    @property
    def is_group(self) -> bool:
        return len(self.windows) > 1

    @property
    def leader(self) -> WindowSpec:
        if self.is_group:
            return next(
                (w for w in self.windows if w.is_group_leader), self.windows[0]
            )
        return self.windows[0]

    @property
    def representative(self) -> WindowSpec:
        """The window whose address represents this cell in live queries."""
        return self.leader


class WorkspaceLayout:
    """Parsed representation of one workspace."""

    def __init__(self, ws_id: int, columns: list[list[Cell]]):
        self.ws_id = ws_id
        self.columns = columns  # columns[col][row] = Cell

    def all_cells(self) -> list[Cell]:
        """Cells in matrix order: column 0 top→bottom, then column 1, etc."""
        return [cell for col in self.columns for cell in col]

    def all_windows(self) -> list[WindowSpec]:
        return [w for cell in self.all_cells() for w in cell.windows]

    def tiled_slots(self) -> list[Cell]:
        """One Cell per tiling slot (groups count as one slot)."""
        return self.all_cells()


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------


def load_layout(path: Path) -> tuple[str, list[WorkspaceLayout]]:
    try:
        raw = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as e:
        sys.exit(f"Error reading layout: {e}")

    name = raw.get("name", "unnamed")
    workspaces: list[WorkspaceLayout] = []

    for ws_str, ws_data in raw.get("workspaces", {}).items():
        ws_id = int(ws_str)
        windows = {
            wid: WindowSpec(wid, data)
            for wid, data in ws_data["windows"].items()
        }

        columns: list[list[Cell]] = []
        for col_raw in ws_data["matrix"]:
            col: list[Cell] = []
            for cell_raw in col_raw:
                if isinstance(cell_raw, list):
                    # Group cell
                    members = [windows[str(wid)] for wid in cell_raw]
                    col.append(Cell(members))
                else:
                    # Single window cell
                    col.append(Cell([windows[str(cell_raw)]]))
            columns.append(col)

        workspaces.append(WorkspaceLayout(ws_id, columns))

    return name, workspaces


def load_registry(path: Path) -> dict[str, str]:
    if not path.exists():
        sys.exit(f"Error: apps.json not found: {path}")
    raw = json.loads(path.read_text())
    apps = raw.get("apps", raw)
    return {k: v for k, v in apps.items() if not k.startswith("_")}


def preflight(
    workspaces: list[WorkspaceLayout], registry: dict[str, str]
) -> None:
    missing = sorted(
        {
            w.wm_class
            for ws in workspaces
            for w in ws.all_windows()
            if w.wm_class not in registry
        }
    )
    if missing:
        sys.exit(
            f"Error: no launch command for: {', '.join(missing)}\nAdd to apps.json."
        )


# ---------------------------------------------------------------------------
# hyprctl helpers
# ---------------------------------------------------------------------------


def hctl(*args: str) -> str:
    r = subprocess.run(["hyprctl", *args], capture_output=True, text=True)
    return r.stdout.strip()


def hctl_json(*args: str) -> list | dict:
    r = subprocess.run(["hyprctl", *args, "-j"], capture_output=True, text=True)
    try:
        return json.loads(r.stdout)
    except json.JSONDecodeError:
        return []


def batch(commands: list[str]) -> None:
    subprocess.run(
        ["hyprctl", "--batch", "; ".join(commands)],
        capture_output=True,
        text=True,
    )


def dispatch(cmd: str, *args: str) -> None:
    hctl("dispatch", cmd, *args)


def get_clients() -> list[dict]:
    return hctl_json("clients")


def known_addresses() -> set[str]:
    return {c["address"] for c in get_clients()}


def lock_groups() -> None:
    """Prevent any group from absorbing new windows globally."""
    dispatch("lockgroups", "lock")


def unlock_groups() -> None:
    """Re-allow group absorption (called only during group formation)."""
    dispatch("lockgroups", "unlock")


def focus_workspace(ws_id: int) -> None:
    """Switch Hyprland's active workspace before launching windows there."""
    dispatch("workspace", str(ws_id))


# ---------------------------------------------------------------------------
# Windowrule helpers
# ---------------------------------------------------------------------------


def set_staging_rule(initial_class: str) -> None:
    hctl(
        "keyword",
        "windowrulev2",
        f"workspace {STAGING_WS} silent,initialclass:^({initial_class})$",
    )


def clear_rule(initial_class: str) -> None:
    hctl("keyword", "windowrulev2", f"unset,initialclass:^({initial_class})$")


# ---------------------------------------------------------------------------
# Window waiting
# ---------------------------------------------------------------------------


def wait_for_window(
    wm_class: str, before: set[str], timeout: float
) -> dict | None:
    """Poll until a new client of wm_class appears. Returns the client dict."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        time.sleep(POLL_INTERVAL)
        for c in get_clients():
            if c["address"] in before:
                continue
            if (c.get("class") or "").lower() == wm_class.lower():
                return c
    return None


# ---------------------------------------------------------------------------
# Launch phase: fire all windows onto staging workspace
# ---------------------------------------------------------------------------


def launch_workspace(ws: WorkspaceLayout, registry: dict[str, str]) -> bool:
    """
    Launch every window in the workspace onto STAGING_WS, sequentially.
    Each cell is launched fully before the next (within a cell, each group
    member is launched and confirmed before the next member).

    Returns True if all windows were confirmed.
    """
    all_ok = True
    print(
        f"\n  Launching ws{ws.ws_id} ({len(ws.all_windows())} window(s))…",
        file=sys.stderr,
    )

    # Switch to this workspace first so new windows feel "at home" here
    # and cannot be absorbed by groups on other workspaces.
    focus_workspace(ws.ws_id)
    time.sleep(0.15)

    for cell in ws.all_cells():
        for win in cell.windows:
            before = known_addresses()
            set_staging_rule(win.initial_class)

            cmd = registry[win.wm_class]
            print(f"    → {cmd}  ({win.wm_class})", file=sys.stderr)
            subprocess.Popen(
                cmd,
                shell=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

            client = wait_for_window(win.wm_class, before, WINDOW_TIMEOUT)
            clear_rule(win.initial_class)

            if client is None:
                print(
                    f"    [warn] {win.wm_class} (id={win.wid}) never appeared",
                    file=sys.stderr,
                )
                all_ok = False
                continue

            win.address = client["address"]
            print(
                f"    ✓ {win.wm_class} id={win.wid} → {win.address}",
                file=sys.stderr,
            )

    return all_ok


# ---------------------------------------------------------------------------
# Move phase: send windows to real workspace ONE AT A TIME, verified
# ---------------------------------------------------------------------------


def wait_on_workspace(address: str, ws_id: int, timeout: float = 5.0) -> bool:
    """
    Poll until hyprctl confirms `address` is on workspace `ws_id`.
    Returns True if confirmed within timeout.
    """
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        for c in get_clients():
            if c["address"] == address and c["workspace"]["id"] == ws_id:
                return True
        time.sleep(POLL_INTERVAL)
    return False


def wait_for_all_on_workspace(
    ws: WorkspaceLayout, timeout: float = 10.0
) -> bool:
    """
    After all moves are issued, poll until every window in the workspace
    reports being on ws_id. Returns True if all confirmed.
    """
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        clients = {c["address"]: c["workspace"]["id"] for c in get_clients()}
        all_placed = all(
            w.address and clients.get(w.address) == ws.ws_id
            for w in ws.all_windows()
            if w.address
        )
        if all_placed:
            return True
        time.sleep(POLL_INTERVAL)
    return False


def move_window(win: WindowSpec, ws_id: int) -> bool:
    """Move a single window to ws_id and wait for confirmation."""
    if win.address is None:
        return False
    dispatch("movetoworkspacesilent", f"{ws_id},address:{win.address}")
    ok = wait_on_workspace(win.address, ws_id, timeout=4.0)
    if ok:
        print(
            f"    ✓ {win.wm_class} id={win.wid} landed on ws{ws_id}",
            file=sys.stderr,
        )
    else:
        print(
            f"    [warn] {win.wm_class} id={win.wid} move not confirmed",
            file=sys.stderr,
        )
    return ok


def move_to_workspace(ws: WorkspaceLayout) -> None:
    """
    Move windows from staging to their real workspace using a two-pass
    strategy that preserves column structure.

    The problem with naive matrix-order moves (col0 row0, col0 row1,
    col1 row0, …): when the second window of a column arrives, Hyprland
    splits whichever tile is currently largest — which may be in the wrong
    column. For example with [[brave], [ghostty, ghostty]], moving brave
    then ghostty-1 creates two equal columns. Moving ghostty-2 then splits
    the active column (brave's column) instead of ghostty's column.

    Two-pass fix:
      Pass 1 — move only the FIRST row of every column, left→right.
                This establishes the correct column structure.
                After each move, focus that window so the next column's
                first window lands next to it rather than splitting it.
      Pass 2 — for each column with multiple rows, focus the last-placed
                window in that column (so Hyprland knows which tile to
                split), then move each additional row window into it.
    """
    print(f"\n  Moving ws{ws.ws_id} windows to workspace…", file=sys.stderr)

    # Pass 1: first row of every column
    print("    Pass 1: establishing columns…", file=sys.stderr)
    last_moved: WindowSpec | None = None
    for col in ws.columns:
        if not col:
            continue
        first_cell = col[0]
        # For a group cell, move the leader first (it's the representative)
        first_win = (
            first_cell.leader if first_cell.is_group else first_cell.windows[0]
        )

        if first_win.address is None:
            continue

        # Focus the previously moved window so this one lands beside it
        # (creates a new column rather than splitting the previous column)
        if last_moved and last_moved.address:
            dispatch("focuswindow", f"address:{last_moved.address}")
            time.sleep(0.1)

        move_window(first_win, ws.ws_id)
        last_moved = first_win

        # For group cells: move non-leader members after the leader
        # (they share the same slot, not a new row)
        if first_cell.is_group:
            for member in first_cell.windows:
                if member is first_win:
                    continue
                move_window(member, ws.ws_id)

    # Pass 2: additional rows within each column
    print("    Pass 2: stacking rows…", file=sys.stderr)
    for col in ws.columns:
        if len(col) < 2:
            continue
        for row_idx, cell in enumerate(col[1:], start=1):
            # Find the window already placed in this column (previous row)
            prev_cell = col[row_idx - 1]
            anchor = (
                prev_cell.leader if prev_cell.is_group else prev_cell.windows[0]
            )

            if anchor.address:
                # Focus the anchor so Hyprland splits THIS column vertically
                dispatch("focuswindow", f"address:{anchor.address}")
                time.sleep(0.15)

            leader = cell.leader if cell.is_group else cell.windows[0]
            move_window(leader, ws.ws_id)

            # Move remaining group members if this is a group cell
            if cell.is_group:
                for member in cell.windows:
                    if member is leader:
                        continue
                    move_window(member, ws.ws_id)

    # Final confirmation
    print(f"    Verifying all windows on ws{ws.ws_id}…", file=sys.stderr)
    ok = wait_for_all_on_workspace(ws, timeout=8.0)
    if ok:
        print(f"    ✓ all windows confirmed on ws{ws.ws_id}", file=sys.stderr)
    else:
        print(
            f"    [warn] not all windows confirmed on ws{ws.ws_id} — continuing anyway",
            file=sys.stderr,
        )

    # Let Hyprland finish tiling before we inspect positions
    time.sleep(0.5)


# ---------------------------------------------------------------------------
# Arrange phase: verify and fix tiling order
# ---------------------------------------------------------------------------


def get_live_slots(ws_id: int, all_addresses: set[str]) -> list[dict]:
    """
    Return one client per tiling slot on the workspace, sorted by (x, y).
    Groups are deduplicated to their leader (first in grouped[]).
    Only addresses we launched are considered.
    """
    clients = get_clients()
    tiled = [
        c
        for c in clients
        if c["workspace"]["id"] == ws_id
        and not c["floating"]
        and c["address"] in all_addresses
    ]

    seen_group_keys: set[str] = set()
    deduped: list[dict] = []
    for c in tiled:
        grouped = c.get("grouped", [])
        if grouped:
            key = grouped[0]
            if key in seen_group_keys:
                continue
            seen_group_keys.add(key)
            leader_client = next((x for x in tiled if x["address"] == key), c)
            deduped.append(leader_client)
        else:
            deduped.append(c)

    deduped.sort(key=lambda c: (c["at"][0], c["at"][1]))
    return deduped


def swap_direction(a: dict, b: dict) -> str:
    """
    Determine the correct swapwindow direction to move window `a`
    toward window `b`, based on their live positions.

    If the X difference dominates → horizontal neighbours → use 'r'.
    If the Y difference dominates → vertical neighbours → use 'd'.
    """
    dx = abs(b["at"][0] - a["at"][0])
    dy = abs(b["at"][1] - a["at"][1])
    return "r" if dx >= dy else "d"


def arrange_workspace(ws: WorkspaceLayout) -> None:
    """
    Verify the live tiling order matches the matrix order and fix it
    using swapwindow with direction inferred from actual window positions.

    Live slots are sorted by (x, y) — same order capture.py uses to build
    the matrix. We bubble-sort adjacent pairs using the direction that
    points from the left/upper window toward its right/lower neighbour.
    """
    slots = ws.tiled_slots()
    if len(slots) < 2:
        return

    expected: list[str | None] = [
        cell.representative.address for cell in slots
    ]
    if any(a is None for a in expected):
        print(
            f"    [warn] ws{ws.ws_id}: some windows unmatched, skipping arrange",
            file=sys.stderr,
        )
        return

    all_addr = {w.address for w in ws.all_windows() if w.address}
    addr_to_slot = {addr: i for i, addr in enumerate(expected)}

    n = len(expected)
    for _pass in range(n):
        live = get_live_slots(ws.ws_id, all_addr)
        if not live:
            break

        swapped = False
        for i in range(len(live) - 1):
            la = live[i]["address"]
            ra = live[i + 1]["address"]
            ls = addr_to_slot.get(la)
            rs = addr_to_slot.get(ra)
            if ls is None or rs is None:
                continue
            if ls > rs:
                direction = swap_direction(live[i], live[i + 1])
                print(
                    f"    swap {direction}: {live[i]['class']} (slot {ls}) ↔ "
                    f"{live[i + 1]['class']} (slot {rs})",
                    file=sys.stderr,
                )
                batch(
                    [
                        f"dispatch focuswindow address:{la}",
                        f"dispatch swapwindow {direction}",
                    ]
                )
                time.sleep(SWAP_SETTLE)
                swapped = True
        if not swapped:
            break


# ---------------------------------------------------------------------------
# Resize phase
# ---------------------------------------------------------------------------


def resize_workspace(ws: WorkspaceLayout) -> None:
    """
    Resize each tiling slot to its saved dimensions.
    Resize all but the last slot (the last takes the remainder).
    Uses `resizeactive exact W H` — Hyprland applies whichever axis
    is relevant (W for horizontal splits, H for vertical stacks).
    """
    slots = ws.tiled_slots()
    if len(slots) < 2:
        return

    for cell in slots[:-1]:
        win = cell.representative
        if win.address is None:
            continue
        print(
            f"    resize: {win.wm_class} id={win.wid} → {win.width}×{win.height}",
            file=sys.stderr,
        )
        batch(
            [
                f"dispatch focuswindow address:{win.address}",
                f"dispatch resizeactive exact {win.width} {win.height}",
            ]
        )
        time.sleep(RESIZE_SETTLE)


# ---------------------------------------------------------------------------
# Group phase
# ---------------------------------------------------------------------------


def get_grouped_addrs(address: str) -> set[str]:
    for c in get_clients():
        if c["address"] == address:
            g = c.get("grouped", [])
            return set(g) if g else {address}
    return set()


def verify_group(members: list[WindowSpec]) -> bool:
    expected = {w.address for w in members}
    return all(get_grouped_addrs(w.address) == expected for w in members)


def form_group(cell: Cell) -> None:
    if not cell.is_group:
        return
    leader = cell.leader
    followers = [w for w in cell.windows if w is not leader]

    if any(w.address is None for w in cell.windows):
        print(
            "    [warn] group skipped — not all members matched",
            file=sys.stderr,
        )
        return

    print(
        f"    group: [{leader.wm_class}] + {[f.wm_class for f in followers]}",
        file=sys.stderr,
    )

    for attempt in range(1, GROUP_RETRIES + 1):
        # Unlock globally so moveintogroup can work, then re-lock immediately after
        unlock_groups()

        # Create group on leader
        batch(
            [
                f"dispatch focuswindow address:{leader.address}",
                "dispatch togglegroup",
            ]
        )
        time.sleep(0.2)

        # Pull each follower in — try all four directions
        for f in followers:
            batch(
                [
                    f"dispatch focuswindow address:{f.address}",
                    "dispatch moveintogroup l",
                    "dispatch moveintogroup r",
                    "dispatch moveintogroup u",
                    "dispatch moveintogroup d",
                ]
            )
            time.sleep(0.2)

        # Restore leader as active tab
        batch([f"dispatch focuswindow address:{leader.address}"])
        time.sleep(0.2)

        # Lock immediately — group is formed, don't let anything else in
        lock_groups()

        if verify_group(cell.windows):
            print(f"    ✓ group verified (attempt {attempt})", file=sys.stderr)
            return

        print(f"    ✗ attempt {attempt} failed, dissolving…", file=sys.stderr)
        unlock_groups()
        for w in cell.windows:
            if len(get_grouped_addrs(w.address)) > 1:
                batch(
                    [
                        f"dispatch focuswindow address:{w.address}",
                        "dispatch togglegroup",
                    ]
                )
        lock_groups()
        time.sleep(GROUP_RETRY_DELAY)

    print(
        f"    [warn] group could not be verified after {GROUP_RETRIES} attempts",
        file=sys.stderr,
    )


def form_groups(ws: WorkspaceLayout) -> None:
    group_cells = [cell for cell in ws.all_cells() if cell.is_group]
    if not group_cells:
        return
    print(
        f"\n  Forming {len(group_cells)} group(s) on ws{ws.ws_id}…",
        file=sys.stderr,
    )
    for cell in group_cells:
        form_group(cell)


# ---------------------------------------------------------------------------
# Main orchestration
# ---------------------------------------------------------------------------


def run(
    layout_path: Path,
    apps_path: Path,
    timeout: float,
    no_arrange: bool,
    no_groups: bool,
) -> None:

    name, workspaces = load_layout(layout_path)
    registry = load_registry(apps_path)
    preflight(workspaces, registry)

    total_windows = sum(len(ws.all_windows()) for ws in workspaces)
    print(
        f"Layout '{name}' — {len(workspaces)} workspace(s), "
        f"{total_windows} window(s)",
        file=sys.stderr,
    )

    # Lock groups globally for the entire launch so no window accidentally
    # gets absorbed by a group on a different workspace.
    # Individual group formation temporarily unlocks, then re-locks.
    lock_groups()
    print("  Group lock: ON", file=sys.stderr)

    for ws in workspaces:
        print(
            f"\n── Workspace {ws.ws_id} ──────────────────────", file=sys.stderr
        )

        ok = launch_workspace(ws, registry)
        if not ok:
            print(
                f"  [warn] some windows on ws{ws.ws_id} failed to launch",
                file=sys.stderr,
            )

        move_to_workspace(ws)

        if not no_arrange:
            print(f"\n  Arranging ws{ws.ws_id}…", file=sys.stderr)
            arrange_workspace(ws)
            time.sleep(0.2)
            resize_workspace(ws)

        if not no_groups:
            form_groups(ws)

    # Release global group lock — user's normal workflow can resume
    unlock_groups()
    print("\n  Group lock: OFF", file=sys.stderr)
    print("\nDone.", file=sys.stderr)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> None:
    p = argparse.ArgumentParser(description="Launch a saved Hyprland layout.")
    p.add_argument("layout", type=Path)
    p.add_argument(
        "--apps", "-a", type=Path, default=Path(__file__).parent / "apps.json"
    )
    p.add_argument("--timeout", "-t", type=float, default=WINDOW_TIMEOUT)
    p.add_argument(
        "--no-arrange",
        action="store_true",
        help="Skip tiling order and resize correction.",
    )
    p.add_argument(
        "--no-groups", action="store_true", help="Skip group formation."
    )
    args = p.parse_args()

    run(args.layout, args.apps, args.timeout, args.no_arrange, args.no_groups)


if __name__ == "__main__":
    main()

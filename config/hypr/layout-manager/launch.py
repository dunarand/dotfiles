#!/usr/bin/env python3
"""
launch.py — Hyprland Layout Launcher
Reads a saved layout JSON (produced by capture.py) and recreates it:
  1. Validates every wm_class has a launch command in apps.json
  2. Sets temporary windowrulev2 rules so each app lands on the right workspace
  3. Launches ungrouped windows first (concurrent), then group members
     sequentially — waiting for each to appear before launching the next
  4. Applies floating geometry where needed
  5. Forms groups and verifies membership, retrying if Hyprland didn't take
  6. Cleans up all temporary windowrules

Usage:
    python3 launch.py <layout.json> [--apps <apps.json>] [--timeout 30]
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

POLL_INTERVAL = 0.25  # seconds between hyprctl polls
DEFAULT_TIMEOUT = 30  # seconds to wait for all windows to appear
GROUP_RETRY_LIMIT = 5  # max attempts to form a single group
GROUP_RETRY_DELAY = 0.4  # seconds between group formation retries
LAUNCH_STAGGER = 0.15  # seconds between ungrouped launches
GROUPED_WAIT = 8.0  # per-window timeout when launching group members


# ---------------------------------------------------------------------------
# Data model (mirrors the output of capture.py)
# ---------------------------------------------------------------------------


@dataclass
class Geometry:
    x: int
    y: int
    width: int
    height: int


@dataclass
class LayoutWindow:
    wm_class: str
    initial_class: str
    initial_title: str
    workspace_id: int
    floating: bool
    geometry: Optional[Geometry]  # only for floating windows
    group_index: Optional[int]
    is_group_leader: bool

    # Filled in after the window appears on screen
    address: Optional[str] = field(default=None, compare=False)


@dataclass
class Layout:
    name: str
    windows: list[LayoutWindow]
    groups: list[list[int]]  # each inner list = window indices in a group


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------


def load_layout(path: Path) -> Layout:
    try:
        raw = json.loads(path.read_text())
    except (OSError, json.JSONDecodeError) as exc:
        sys.exit(f"Error reading layout file: {exc}")

    windows: list[LayoutWindow] = []
    for w in raw.get("windows", []):
        geo: Optional[Geometry] = None
        if w.get("floating") and "geometry" in w:
            g = w["geometry"]
            geo = Geometry(
                x=g["x"], y=g["y"], width=g["width"], height=g["height"]
            )

        windows.append(
            LayoutWindow(
                wm_class=w["wm_class"],
                initial_class=w["initial_class"],
                initial_title=w["initial_title"],
                workspace_id=w["workspace_id"],
                floating=w.get("floating", False),
                geometry=geo,
                group_index=w.get("group_index"),
                is_group_leader=w.get("is_group_leader", False),
            )
        )

    return Layout(
        name=raw.get("name", "unnamed"),
        windows=windows,
        groups=raw.get("groups", []),
    )


def load_app_registry(path: Path) -> dict[str, str]:
    """Return wm_class -> launch command mapping from apps.json's 'apps' key."""
    if not path.exists():
        sys.exit(f"Error: app registry not found: {path}")
    try:
        raw = json.loads(path.read_text())
    except json.JSONDecodeError as exc:
        sys.exit(f"Error reading apps.json: {exc}")
    apps = raw.get("apps", raw)  # fall back to flat format for compatibility
    return {k: v for k, v in apps.items() if not k.startswith("_")}


# ---------------------------------------------------------------------------
# hyprctl helpers
# ---------------------------------------------------------------------------


def hyprctl(*args: str) -> str:
    result = subprocess.run(["hyprctl", *args], capture_output=True, text=True)
    return result.stdout.strip()


def hyprctl_json(*args: str) -> list | dict:
    result = subprocess.run(
        ["hyprctl", *args, "-j"], capture_output=True, text=True
    )
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return []


def hyprctl_batch(commands: list[str]) -> None:
    """Run multiple dispatch commands atomically via `hyprctl --batch`."""
    subprocess.run(
        ["hyprctl", "--batch", "; ".join(commands)],
        capture_output=True,
        text=True,
    )


def dispatch(command: str, *args: str) -> None:
    hyprctl("dispatch", command, *args)


def get_current_clients() -> list[dict]:
    return hyprctl_json("clients")


# ---------------------------------------------------------------------------
# Windowrule management — floating windows only
# ---------------------------------------------------------------------------


def add_float_rule(initial_class: str) -> None:
    """Force a window to float at spawn time (for floating layout windows)."""
    hyprctl(
        "keyword", "windowrulev2", f"float,initialclass:^({initial_class})$"
    )


def remove_float_rules(initial_classes: list[str]) -> None:
    for cls in set(initial_classes):
        hyprctl("keyword", "windowrulev2", f"unset,initialclass:^({cls})$")


# ---------------------------------------------------------------------------
# Staging workspace
#
# All windows are launched onto a hidden staging workspace (workspace 99 by
# default) so they never appear on a real workspace mid-launch and never
# fight each other for tiling slots on the target workspace.
# Once matched, each window is moved to its real workspace individually.
# This sidesteps the duplicate-class windowrule problem entirely: we don't
# need a rule per window — just "land on staging" for all of them.
# ---------------------------------------------------------------------------

STAGING_WS = 99  # must not be a workspace the user cares about


def add_staging_rule(initial_class: str) -> None:
    hyprctl(
        "keyword",
        "windowrulev2",
        f"workspace {STAGING_WS} silent,initialclass:^({initial_class})$",
    )


def remove_staging_rules(initial_classes: list[str]) -> None:
    for cls in set(initial_classes):
        hyprctl("keyword", "windowrulev2", f"unset,initialclass:^({cls})$")


# ---------------------------------------------------------------------------
# Window matching
# ---------------------------------------------------------------------------


def snapshot_addresses(clients: list[dict]) -> set[str]:
    return {c["address"] for c in clients}


def wait_for_new_window(
    wm_class: str,
    known: set[str],
    timeout: float,
) -> Optional[dict]:
    """Poll until a new client with the given wm_class appears anywhere."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        time.sleep(POLL_INTERVAL)
        for client in get_current_clients():
            if client["address"] in known:
                continue
            if (client.get("class") or "").lower() == wm_class.lower():
                return client
    return None


def match_new_window(
    candidate: dict,
    unmatched: list[LayoutWindow],
) -> Optional[LayoutWindow]:
    """
    Match a newly appeared client to the best unmatched LayoutWindow slot.

    Since all windows land on the staging workspace, we can no longer use
    workspace_id as a tiebreaker between same-class duplicates. Instead we
    match strictly by arrival order — the first unmatched slot for that class
    wins. Launch order is controlled by the caller to make this correct.
    """
    client_class = (candidate.get("class") or "").lower()
    same_class = [w for w in unmatched if w.wm_class.lower() == client_class]
    return same_class[0] if same_class else None


# ---------------------------------------------------------------------------
# Placement
# ---------------------------------------------------------------------------


def place_window(win: LayoutWindow) -> None:
    """Move window to its real workspace, apply floating geometry if needed."""
    assert win.address is not None

    # Move from staging to the real workspace
    dispatch(
        "movetoworkspacesilent", f"{win.workspace_id},address:{win.address}"
    )

    if win.floating and win.geometry is not None:
        dispatch("setfloating", f"address:{win.address}")
        geo = win.geometry
        dispatch(
            "movewindowpixel", f"exact {geo.x} {geo.y},address:{win.address}"
        )
        dispatch(
            "resizewindowpixel",
            f"exact {geo.width} {geo.height},address:{win.address}",
        )


# ---------------------------------------------------------------------------
# Grouping with verification and retry  (Option D)
# ---------------------------------------------------------------------------


def get_grouped_addresses(address: str) -> set[str]:
    """Return the set of addresses in the same group as `address`."""
    for client in get_current_clients():
        if client["address"] == address:
            grouped = client.get("grouped", [])
            return set(grouped) if grouped else {address}
    return set()


def verify_group(members: list[LayoutWindow]) -> bool:
    """Return True if every member reports the full expected group."""
    expected = {w.address for w in members}
    for w in members:
        if get_grouped_addresses(w.address) != expected:
            return False
    return True


def form_single_group(
    leader: LayoutWindow, followers: list[LayoutWindow]
) -> bool:
    """Attempt to form one group. Returns True if verified successful."""
    for attempt in range(1, GROUP_RETRY_LIMIT + 1):
        print(
            f"    attempt {attempt}/{GROUP_RETRY_LIMIT}: "
            f"[{leader.wm_class}] + {[f.wm_class for f in followers]}",
            file=sys.stderr,
        )

        # Create the group container on the leader
        hyprctl_batch(
            [
                f"dispatch focuswindow address:{leader.address}",
                "dispatch togglegroup",
            ]
        )
        time.sleep(0.2)

        # Pull each follower in — try all four directions, one will succeed
        for follower in followers:
            hyprctl_batch(
                [
                    f"dispatch focuswindow address:{follower.address}",
                    "dispatch moveintogroup l",
                    "dispatch moveintogroup r",
                    "dispatch moveintogroup u",
                    "dispatch moveintogroup d",
                ]
            )
            time.sleep(0.2)

        # Restore leader as active tab
        hyprctl_batch([f"dispatch focuswindow address:{leader.address}"])
        time.sleep(0.2)

        if verify_group([leader] + followers):
            print(f"    ✓ group verified on attempt {attempt}", file=sys.stderr)
            return True

        # Dissolve partial group before retrying
        print(
            f"    ✗ verification failed, dissolving and retrying…",
            file=sys.stderr,
        )
        for member in [leader] + followers:
            if len(get_grouped_addresses(member.address)) > 1:
                hyprctl_batch(
                    [
                        f"dispatch focuswindow address:{member.address}",
                        "dispatch togglegroup",
                    ]
                )
        time.sleep(GROUP_RETRY_DELAY)

    return False


def form_groups(layout: Layout) -> None:
    for group_indices in layout.groups:
        if len(group_indices) < 2:
            continue

        members = [layout.windows[i] for i in group_indices]
        if any(w.address is None for w in members):
            print(
                f"  [warn] Skipping group {group_indices} — "
                "not all windows were matched.",
                file=sys.stderr,
            )
            continue

        leader = next((w for w in members if w.is_group_leader), members[0])
        followers = [w for w in members if w is not leader]

        print(
            f"  Forming group: [{leader.wm_class}] + "
            f"{[f.wm_class for f in followers]}",
            file=sys.stderr,
        )

        if not form_single_group(leader, followers):
            print(
                f"  [warn] Could not verify group after {GROUP_RETRY_LIMIT} attempts.",
                file=sys.stderr,
            )


# ---------------------------------------------------------------------------
# Launch orchestration
# ---------------------------------------------------------------------------


def preflight_check(layout: Layout, registry: dict[str, str]) -> None:
    missing = sorted(
        {w.wm_class for w in layout.windows if w.wm_class not in registry}
    )
    if missing:
        sys.exit(
            f"Error: no launch command found for class(es): {', '.join(missing)}\n"
            f"Add them to apps.json."
        )


def launch_all(
    layout: Layout,
    registry: dict[str, str],
    timeout: float,
) -> bool:
    """
    Staging-workspace launch strategy:

    All windows — regardless of class or target workspace — are routed to
    workspace STAGING_WS at spawn via a single staging windowrule per class.
    This means duplicate classes (e.g. two Brave windows) never collide on
    a real workspace and never stack unexpectedly.

    Launch order:
      1. Ungrouped windows: all launched with a short stagger, then we poll
         until each appears and move it to its real workspace.
      2. Group members: launched one at a time within each group, waiting
         for each window to confirm before launching the next. Order within
         the group is preserved, so by the time we form the group the
         windows are tiled side-by-side in the correct sequence.

    Staging rules are set just before each launch and removed immediately
    after that window is confirmed, so a slow-starting app of the same class
    can never inherit a rule meant for a different slot.
    """
    grouped_indices: set[int] = {i for group in layout.groups for i in group}
    ungrouped = [
        w for i, w in enumerate(layout.windows) if i not in grouped_indices
    ]

    known = snapshot_addresses(get_current_clients())
    float_rules_added: list[str] = []

    # ── Wave 1: ungrouped windows ─────────────────────────────────────────

    if ungrouped:
        print(f"Wave 1: {len(ungrouped)} ungrouped window(s)…", file=sys.stderr)

        for win in ungrouped:
            # Staging rule so it doesn't appear on a real workspace yet
            add_staging_rule(win.initial_class)
            if win.floating:
                add_float_rule(win.initial_class)
                float_rules_added.append(win.initial_class)

            print(
                f"  → {registry[win.wm_class]}  ({win.wm_class} → ws{win.workspace_id})",
                file=sys.stderr,
            )
            subprocess.Popen(
                registry[win.wm_class],
                shell=True,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            time.sleep(LAUNCH_STAGGER)

        # Wait and match all ungrouped windows
        unmatched = list(ungrouped)
        deadline = time.monotonic() + timeout
        while unmatched and time.monotonic() < deadline:
            time.sleep(POLL_INTERVAL)
            for client in get_current_clients():
                if client["address"] in known:
                    continue
                win = match_new_window(client, unmatched)
                if win is None:
                    continue
                win.address = client["address"]
                known.add(client["address"])
                unmatched.remove(win)
                # Remove staging rule as soon as this window is claimed
                remove_staging_rules([win.initial_class])
                print(
                    f"  ✓ {win.wm_class} → {client['address']}", file=sys.stderr
                )
                place_window(win)

        if unmatched:
            print(
                f"  [warn] Timed out waiting for: {[w.wm_class for w in unmatched]}",
                file=sys.stderr,
            )
            for w in unmatched:
                remove_staging_rules([w.initial_class])

    # ── Wave 2: grouped windows, one per group, strictly sequential ───────

    if layout.groups:
        total_grouped = sum(len(g) for g in layout.groups)
        print(
            f"\nWave 2: {total_grouped} grouped window(s), sequentially…",
            file=sys.stderr,
        )

        for group_indices in layout.groups:
            members = [layout.windows[i] for i in group_indices]
            print(
                f"  Group [{' + '.join(m.wm_class for m in members)}]",
                file=sys.stderr,
            )

            for win in members:
                # Set staging rule immediately before this specific launch
                add_staging_rule(win.initial_class)
                if win.floating:
                    add_float_rule(win.initial_class)
                    float_rules_added.append(win.initial_class)

                print(
                    f"    → {registry[win.wm_class]}  ({win.wm_class} → ws{win.workspace_id})",
                    file=sys.stderr,
                )
                subprocess.Popen(
                    registry[win.wm_class],
                    shell=True,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )

                # Wait for THIS window before proceeding to the next
                client = wait_for_new_window(
                    win.wm_class, known, timeout=GROUPED_WAIT
                )

                # Remove staging rule immediately — before next launch
                remove_staging_rules([win.initial_class])

                if client is None:
                    print(
                        f"    [warn] {win.wm_class} never appeared, skipping…",
                        file=sys.stderr,
                    )
                    continue

                win.address = client["address"]
                known.add(client["address"])
                print(
                    f"    ✓ {win.wm_class} → {client['address']}",
                    file=sys.stderr,
                )
                place_window(win)

    # ── Clean up any remaining float rules ───────────────────────────────

    if float_rules_added:
        remove_float_rules(float_rules_added)

    # ── Report ────────────────────────────────────────────────────────────

    failed = [w for w in layout.windows if w.address is None]
    if failed:
        print(
            f"\n[warn] {len(failed)} window(s) never matched:", file=sys.stderr
        )
        for w in failed:
            print(f"  - {w.wm_class} (ws{w.workspace_id})", file=sys.stderr)
        return False

    print("\nAll windows placed.", file=sys.stderr)
    return True


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def build_arg_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Launch and place a saved Hyprland layout.",
    )
    p.add_argument(
        "layout",
        type=Path,
        help="Path to the layout JSON file (produced by capture.py).",
    )
    p.add_argument(
        "--apps",
        "-a",
        type=Path,
        default=Path(__file__).parent / "apps.json",
        help="Path to the app registry JSON. Default: apps.json next to this script.",
    )
    p.add_argument(
        "--timeout",
        "-t",
        type=float,
        default=DEFAULT_TIMEOUT,
        help=f"Seconds to wait for all windows to appear (default: {DEFAULT_TIMEOUT}).",
    )
    p.add_argument(
        "--no-groups",
        action="store_true",
        help="Skip group reconstruction (useful for debugging placement).",
    )
    return p


def main() -> None:
    parser = build_arg_parser()
    args = parser.parse_args()

    layout = load_layout(args.layout)
    registry = load_app_registry(args.apps)

    print(
        f"Layout: '{layout.name}' — {len(layout.windows)} window(s), "
        f"{len(layout.groups)} group(s)",
        file=sys.stderr,
    )

    preflight_check(layout, registry)
    success = launch_all(layout, registry, timeout=args.timeout)

    if success and not args.no_groups and layout.groups:
        print(f"\nForming {len(layout.groups)} group(s)…", file=sys.stderr)
        time.sleep(0.4)  # let Hyprland settle placements before grouping
        form_groups(layout)

    if not success:
        sys.exit(1)

    print("\nDone.", file=sys.stderr)


if __name__ == "__main__":
    main()

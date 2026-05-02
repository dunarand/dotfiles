#!/usr/bin/env python3
"""
capture.py — Hyprland Layout Capture
Reads current clients via hyprctl, filters ignored windows,
and serialises the layout as a per-workspace 2D matrix.

Matrix format (per workspace):
  Outer list  = columns, sorted left→right by X coordinate
  Inner list  = rows within each column, sorted top→bottom by Y coordinate
  Cell value  = single int ID  (ungrouped window)
               | list of ints  (group: all members share this cell)

Usage:
    python3 capture.py --name <name> [--apps <apps.json>] [--output <file>]
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Ignore rules
# ---------------------------------------------------------------------------


class IgnoreRule:
    def __init__(
        self,
        wm_class: Optional[str] = None,
        title: Optional[str] = None,
        exact: bool = False,
    ):
        self.wm_class = wm_class
        self.title = title
        self.exact = exact

    def matches(self, client: dict) -> bool:
        cls = (client.get("class") or "").lower()
        title = (client.get("title") or "").lower()

        def _match(pattern: str, value: str) -> bool:
            p = pattern.lower()
            return value == p if self.exact else p in value

        if self.wm_class is not None and not _match(self.wm_class, cls):
            return False
        if self.title is not None and not _match(self.title, title):
            return False
        if self.wm_class is None and self.title is None:
            return False
        return True


def load_ignore_rules(apps_path: Path) -> list[IgnoreRule]:
    raw = json.loads(apps_path.read_text())
    return [
        IgnoreRule(
            wm_class=e.get("wm_class"),
            title=e.get("title"),
            exact=bool(e.get("exact", False)),
        )
        for e in raw.get("ignore", [])
    ]


def is_ignored(client: dict, rules: list[IgnoreRule]) -> bool:
    return any(r.matches(client) for r in rules)


# ---------------------------------------------------------------------------
# hyprctl
# ---------------------------------------------------------------------------


def fetch_clients() -> list[dict]:
    try:
        r = subprocess.run(
            ["hyprctl", "clients", "-j"],
            capture_output=True,
            text=True,
            check=True,
        )
    except FileNotFoundError:
        sys.exit("Error: hyprctl not found.")
    except subprocess.CalledProcessError as e:
        sys.exit(f"Error: hyprctl failed:\n{e.stderr}")
    return json.loads(r.stdout)


# ---------------------------------------------------------------------------
# Matrix builder
# ---------------------------------------------------------------------------


def build_workspace_matrix(clients: list[dict]) -> dict:
    """
    Given a list of tiled, non-ignored clients all on the same workspace,
    return a workspace dict:

    {
      "matrix": [[col0_row0, col0_row1, ...], [col1_row0, ...], ...],
      "windows": {
        "1": {"wm_class": ..., "initial_class": ..., "initial_title": ...,
              "width": ..., "height": ..., "is_group_leader": ...},
        ...
      }
    }

    Cell values in the matrix:
      - int               → single window ID
      - [int, int, ...]   → group (all members at this cell position)

    Algorithm:
      1. Deduplicate groups: multiple clients sharing the same grouped[] array
         occupy the same (x, y) cell. Collapse them into one representative
         for column/row assignment; record all their IDs for the cell.
      2. Find unique X values → columns (sorted ascending).
      3. Within each column, sort cells by Y → rows.
      4. Assign sequential IDs (1, 2, 3…) across all cells in reading order
         (left→right, top→bottom within each column).
    """

    if not clients:
        return {"matrix": [], "windows": {}}

    # ── Step 1: collapse groups into cells ──────────────────────────────
    # A "cell" is a unique (x, y) position. Grouped windows share (x, y).
    # We represent each cell as: (x, y, width, height, [client, ...])

    # group_key → list of clients in that group
    # For ungrouped windows, group_key = their own address (unique)
    cell_map: dict[str, list[dict]] = {}

    for c in clients:
        grouped = c.get("grouped", [])
        # Hyprland lists all group members in grouped[]; use the sorted tuple
        # as a stable key so every member maps to the same cell.
        key = tuple(sorted(grouped)) if len(grouped) > 1 else (c["address"],)
        cell_map.setdefault(str(key), []).append(c)

    # Build cell list: (x, y, width, height, [clients])
    cells: list[tuple[int, int, int, int, list[dict]]] = []
    for members in cell_map.values():
        # All members share the same at[] and size[] (they overlap exactly)
        rep = members[0]
        x, y = rep["at"][0], rep["at"][1]
        w, h = rep["size"][0], rep["size"][1]
        cells.append((x, y, w, h, members))

    # ── Step 2 & 3: build columns ────────────────────────────────────────
    # Unique X values → column boundaries
    unique_x = sorted(set(x for x, y, w, h, _ in cells))

    # Group cells by their X column, then sort each column by Y
    columns: list[list[tuple[int, int, int, int, list[dict]]]] = []
    for col_x in unique_x:
        col_cells = [(x, y, w, h, m) for x, y, w, h, m in cells if x == col_x]
        col_cells.sort(key=lambda c: c[1])  # sort by y
        columns.append(col_cells)

    # ── Step 4: assign sequential IDs ───────────────────────────────────
    next_id = 1
    # cell_key → list of assigned IDs (one per group member)
    cell_key_to_ids: dict[str, list[int]] = {}

    # Also need to know which member is the group leader
    # (first address in the grouped[] array = leader in Hyprland)
    def is_leader(client: dict, members: list[dict]) -> bool:
        grouped = client.get("grouped", [])
        if not grouped or len(grouped) == 1:
            return False  # ungrouped — not relevant
        return grouped[0] == client["address"]

    matrix: list[list] = []
    windows: dict[str, dict] = {}

    for col_cells in columns:
        col_entries: list = []
        for x, y, w, h, members in col_cells:
            ids: list[int] = []
            for c in members:
                wid = str(next_id)
                next_id += 1
                ids.append(int(wid))

                entry: dict = {
                    "wm_class": c["class"],
                    "initial_class": c["initialClass"],
                    "initial_title": c["initialTitle"],
                    "width": w,
                    "height": h,
                }
                # Only add group metadata when actually in a multi-member group
                if len(members) > 1:
                    entry["is_group_leader"] = is_leader(c, members)

                windows[wid] = entry

            # Cell = single int for ungrouped, list of ints for group
            col_entries.append(ids[0] if len(ids) == 1 else ids)

        matrix.append(col_entries)

    return {"matrix": matrix, "windows": windows}


# ---------------------------------------------------------------------------
# Main capture
# ---------------------------------------------------------------------------


def capture(apps_path: Path) -> dict:
    rules = load_ignore_rules(apps_path)
    clients = fetch_clients()

    # Filter: drop ignored, special workspaces (id < 0), and floating
    filtered = [
        c
        for c in clients
        if not is_ignored(c, rules)
        and c["workspace"]["id"] > 0
        and not c["floating"]
    ]

    # Group by workspace
    by_ws: dict[int, list[dict]] = {}
    for c in filtered:
        by_ws.setdefault(c["workspace"]["id"], []).append(c)

    workspaces = {}
    for ws_id in sorted(by_ws):
        workspaces[str(ws_id)] = build_workspace_matrix(by_ws[ws_id])

    return workspaces


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def main() -> None:
    p = argparse.ArgumentParser(description="Capture Hyprland layout to JSON.")
    p.add_argument("--name", "-n", default="unnamed")
    p.add_argument("--output", "-o", type=Path, default=None)
    p.add_argument(
        "--apps", "-a", type=Path, default=Path(__file__).parent / "apps.json"
    )
    p.add_argument("--dry-run", action="store_true")
    p.add_argument("--print", "-p", action="store_true", dest="print_output")
    args = p.parse_args()

    workspaces = capture(args.apps)
    payload = {"name": args.name, "workspaces": workspaces}
    json_text = json.dumps(payload, indent=2)

    if not args.dry_run:
        out = args.output or Path(f"{args.name}.json")
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json_text)
        total_windows = sum(len(ws["windows"]) for ws in workspaces.values())
        print(f"Layout '{args.name}' captured → {out}", file=sys.stderr)
        print(
            f"  {len(workspaces)} workspace(s), {total_windows} window(s)",
            file=sys.stderr,
        )

    if args.print_output or args.dry_run:
        print(json_text)


if __name__ == "__main__":
    main()

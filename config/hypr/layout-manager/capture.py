#!/usr/bin/env python3
"""
capture.py — Hyprland Layout Capture
Reads current clients via hyprctl, filters ignored windows,
and serialises the result into a structured layout definition.

Usage:
    python3 capture.py [--output <file.json>] [--name "My Layout"]
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional

# ---------------------------------------------------------------------------
# Ignore rules
# ---------------------------------------------------------------------------


@dataclass
class IgnoreRule:
    """
    A window is ignored when ALL non-None fields match.
    Matching is case-insensitive substring unless exact=True.
    """

    wm_class: Optional[str] = None
    title: Optional[str] = None
    exact: bool = False  # if True, require full-string equality

    def matches(self, client: dict) -> bool:
        client_class = (client.get("class") or "").lower()
        client_title = (client.get("title") or "").lower()

        def _match(pattern: str, value: str) -> bool:
            p = pattern.lower()
            return value == p if self.exact else p in value

        if self.wm_class is not None and not _match(
            self.wm_class, client_class
        ):
            return False
        if self.title is not None and not _match(self.title, client_title):
            return False
        # At least one field must have been specified for the rule to fire
        if self.wm_class is None and self.title is None:
            return False
        return True


def load_ignore_rules(apps_path: Path) -> list[IgnoreRule]:
    """
    Load ignore rules from the 'ignore' key in apps.json.

    Each entry may specify 'wm_class', 'title', or both (AND logic).
    Matching is case-insensitive substring by default; set "exact": true
    for full-string equality.

    Example apps.json entry:
        "ignore": [
            { "wm_class": "Spotify" },
            { "wm_class": "com.mitchellh.ghostty", "title": "btm-monitor" },
            { "title": "Picture-in-Picture", "exact": true }
        ]
    """
    if not apps_path.exists():
        sys.exit(f"Error: apps file not found: {apps_path}")
    try:
        raw = json.loads(apps_path.read_text())
    except json.JSONDecodeError as exc:
        sys.exit(f"Error reading {apps_path}: {exc}")

    rules: list[IgnoreRule] = []
    for entry in raw.get("ignore", []):
        rules.append(
            IgnoreRule(
                wm_class=entry.get("wm_class"),
                title=entry.get("title"),
                exact=bool(entry.get("exact", False)),
            )
        )
    return rules


# ---------------------------------------------------------------------------
# Data model
# ---------------------------------------------------------------------------


@dataclass
class WindowGeometry:
    """Only recorded for floating windows; None for tiled (compositor decides)."""

    x: int
    y: int
    width: int
    height: int


@dataclass
class LayoutWindow:
    """Everything the launcher needs — nothing it doesn't."""

    wm_class: str  # used to identify the window after launch
    initial_class: str  # used to launch / match via windowrule
    initial_title: str  # used to launch / match via windowrule
    workspace_id: int  # target workspace
    floating: bool
    # Only set when floating=True; None otherwise
    geometry: Optional[WindowGeometry]
    # Index into CapturedLayout.groups; None when not part of a group
    group_index: Optional[int]
    # True when this window should be the active tab in its group
    is_group_leader: bool


@dataclass
class CapturedLayout:
    name: str
    windows: list[LayoutWindow] = field(default_factory=list)
    # Each inner list holds window *indices* (into self.windows) that form a group.
    # Addresses are ephemeral; indices are stable in the saved file.
    groups: list[list[int]] = field(default_factory=list)


# ---------------------------------------------------------------------------
# hyprctl helpers
# ---------------------------------------------------------------------------


def fetch_clients() -> list[dict]:
    """Run `hyprctl clients -j` and return the parsed JSON list."""
    try:
        result = subprocess.run(
            ["hyprctl", "clients", "-j"],
            capture_output=True,
            text=True,
            check=True,
        )
    except FileNotFoundError:
        sys.exit("Error: hyprctl not found. Are you running inside Hyprland?")
    except subprocess.CalledProcessError as exc:
        sys.exit(
            f"Error: hyprctl exited with code {exc.returncode}:\n{exc.stderr}"
        )

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        sys.exit(f"Error: could not parse hyprctl output as JSON:\n{exc}")


# ---------------------------------------------------------------------------
# Filtering
# ---------------------------------------------------------------------------


def is_ignored(client: dict, rules: list[IgnoreRule]) -> bool:
    return any(rule.matches(client) for rule in rules)


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------


def parse_clients(
    clients: list[dict],
    ignore_rules: list[IgnoreRule],
) -> CapturedLayout:
    """Filter clients and build a CapturedLayout with lean, launch-ready data."""

    # ------------------------------------------------------------------
    # Pass 1: collect unique address-level groups from raw hyprctl data.
    # A group is the "grouped" array on each client; all members share the
    # same array, so we deduplicate by frozenset.
    # ------------------------------------------------------------------
    addr_groups: list[list[str]] = []  # each entry is an ordered addr list
    seen_group_keys: set[frozenset] = set()

    for c in clients:
        members: list[str] = c.get("grouped", [])
        if len(members) > 1:
            key = frozenset(members)
            if key not in seen_group_keys:
                seen_group_keys.add(key)
                addr_groups.append(members)

    # addr → (group_index_in_addr_groups, is_leader)
    addr_to_group_info: dict[str, tuple[int, bool]] = {}
    for gi, group in enumerate(addr_groups):
        for addr in group:
            is_leader = group[0] == addr
            addr_to_group_info[addr] = (gi, is_leader)

    # ------------------------------------------------------------------
    # Pass 2: filter and build LayoutWindow list.
    # Track which addr_groups survive (not fully ignored) so we can
    # remap to window-index groups afterwards.
    # ------------------------------------------------------------------
    windows: list[LayoutWindow] = []
    # addr → window index in `windows` (for later group remapping)
    addr_to_win_idx: dict[str, int] = {}

    for c in clients:
        if is_ignored(c, ignore_rules):
            continue

        ws_id: int = c["workspace"]["id"]
        if ws_id < 0:  # special / scratchpad workspaces
            continue

        floating: bool = c["floating"]
        geo: Optional[WindowGeometry] = None
        if floating:
            geo = WindowGeometry(
                x=c["at"][0],
                y=c["at"][1],
                width=c["size"][0],
                height=c["size"][1],
            )

        group_info = addr_to_group_info.get(c["address"])
        # group_index and is_group_leader are resolved in Pass 3
        win = LayoutWindow(
            wm_class=c["class"],
            initial_class=c["initialClass"],
            initial_title=c["initialTitle"],
            workspace_id=ws_id,
            floating=floating,
            geometry=geo,
            group_index=group_info[0]
            if group_info
            else None,  # addr-group idx (temporary)
            is_group_leader=group_info[1] if group_info else False,
        )
        addr_to_win_idx[c["address"]] = len(windows)
        windows.append(win)

    # ------------------------------------------------------------------
    # Pass 3: build final index-based groups and patch group_index on
    # each window to point into the final groups list.
    # ------------------------------------------------------------------
    # addr_group_idx → [window indices]
    addr_gi_to_win_indices: dict[int, list[int]] = {}
    for addr, win_idx in addr_to_win_idx.items():
        info = addr_to_group_info.get(addr)
        if info is None:
            continue
        addr_gi = info[0]
        addr_gi_to_win_indices.setdefault(addr_gi, []).append(win_idx)

    # Only keep groups where at least 2 members survived filtering
    final_groups: list[list[int]] = []
    addr_gi_to_final_gi: dict[int, int] = {}
    for addr_gi, win_indices in addr_gi_to_win_indices.items():
        if len(win_indices) >= 2:
            addr_gi_to_final_gi[addr_gi] = len(final_groups)
            # Preserve original order from addr_groups
            ordered = sorted(win_indices, key=lambda i: i)
            final_groups.append(ordered)

    # Patch windows: replace temporary addr-group idx with final idx (or None)
    for win in windows:
        if win.group_index is not None:
            final_gi = addr_gi_to_final_gi.get(win.group_index)
            win.group_index = final_gi  # None if group was culled

    return CapturedLayout(name="", windows=windows, groups=final_groups)


# ---------------------------------------------------------------------------
# Serialisation
# ---------------------------------------------------------------------------


def layout_to_dict(layout: CapturedLayout) -> dict:
    def win_dict(w: LayoutWindow) -> dict:
        d: dict = {
            "wm_class": w.wm_class,
            "initial_class": w.initial_class,
            "initial_title": w.initial_title,
            "workspace_id": w.workspace_id,
            "floating": w.floating,
        }
        if w.floating and w.geometry is not None:
            d["geometry"] = {
                "x": w.geometry.x,
                "y": w.geometry.y,
                "width": w.geometry.width,
                "height": w.geometry.height,
            }
        if w.group_index is not None:
            d["group_index"] = w.group_index
            d["is_group_leader"] = w.is_group_leader
        return d

    return {
        "name": layout.name,
        "groups": layout.groups,
        "windows": [win_dict(w) for w in layout.windows],
    }


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def build_arg_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        description="Capture the current Hyprland client layout to a JSON file.",
    )
    p.add_argument(
        "--name",
        "-n",
        default="",
        help="Human-readable name for this layout (e.g. 'dev-session').",
    )
    p.add_argument(
        "--output",
        "-o",
        type=Path,
        default=None,
        help="Path to write the JSON layout file. "
        "Defaults to <n>.json in the current directory.",
    )
    p.add_argument(
        "--apps",
        "-a",
        type=Path,
        default=Path(__file__).parent / "apps.json",
        help="Path to apps.json (contains ignore rules). "
        "Default: apps.json next to this script.",
    )
    p.add_argument(
        "--print",
        "-p",
        action="store_true",
        dest="print_output",
        help="Print the JSON to stdout in addition to writing a file.",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Parse and print without writing any file.",
    )
    return p


def main() -> None:
    parser = build_arg_parser()
    args = parser.parse_args()

    rules = load_ignore_rules(args.apps)

    raw_clients = fetch_clients()
    layout = parse_clients(raw_clients, rules)
    layout.name = args.name or "unnamed"

    payload = layout_to_dict(layout)
    json_text = json.dumps(payload, indent=2)

    if not args.dry_run:
        out_path: Path = args.output or Path(f"{layout.name}.json")
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json_text)
        print(f"Layout '{layout.name}' captured → {out_path}", file=sys.stderr)
        print(
            f"  {len(layout.windows)} window(s), "
            f"{len(layout.groups)} group(s), "
            f"{sum(1 for w in layout.windows if not w.floating)} tiled, "
            f"{sum(1 for w in layout.windows if w.floating)} floating.",
            file=sys.stderr,
        )

    if args.print_output or args.dry_run:
        print(json_text)


if __name__ == "__main__":
    main()

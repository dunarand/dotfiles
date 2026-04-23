#!/usr/bin/env bash
# layout-manager.sh — Hyprland layout manager with rofi
# Lives at: ~/.config/hypr/layout-manager/layout-manager.sh
#
# Submenus:
#   Load   → pick a layout → move conflicting windows to special:minimized → launch
#   Save   → type a name   → capture current state
#   Delete → pick a layout → confirm → remove the file

set -euo pipefail

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAYOUTS_DIR="$SCRIPT_DIR/layouts"
CAPTURE_PY="$SCRIPT_DIR/capture.py"
LAUNCH_PY="$SCRIPT_DIR/launch.py"
APPS_JSON="$SCRIPT_DIR/apps.json"

mkdir -p "$LAYOUTS_DIR"

# ---------------------------------------------------------------------------
# Notification helper — matches your existing notify-send format
# ---------------------------------------------------------------------------

notify() {
    notify-send \
        -h string:x-canonical-private-synchronous:layout-manager \
        -h int:transient:1 \
        "Layout Manager: $1"
}

# ---------------------------------------------------------------------------
# List available layouts (names without extension)
# ---------------------------------------------------------------------------

list_layouts() {
    # Emits one layout name per line, sorted, without the .json suffix.
    find "$LAYOUTS_DIR" -maxdepth 1 -name "*.json" -printf "%f\n" \
        | sort \
        | sed 's/\.json$//'
}

# ---------------------------------------------------------------------------
# Move windows on the given workspace IDs to special:minimized
# ---------------------------------------------------------------------------

stash_conflicting_windows() {
    # $@ = list of workspace IDs (integers) the layout will occupy
    local -a ws_ids=("$@")
    local stashed=0

    # Get all current clients as JSON, then iterate
    local clients
    clients="$(hyprctl clients -j)"

    for ws_id in "${ws_ids[@]}"; do
        # Extract addresses of windows sitting on this workspace
        local addrs
        mapfile -t addrs < <(
            echo "$clients" \
                | jq -r --argjson ws "$ws_id" \
                    '.[] | select(.workspace.id == $ws) | .address'
        )

        for addr in "${addrs[@]}"; do
            [[ -z "$addr" ]] && continue
            hyprctl dispatch movetoworkspacesilent \
                "special:minimized,address:$addr" \
                > /dev/null
            ((stashed++)) || true
        done
    done

    if ((stashed > 0)); then
        notify "Moved $stashed window(s) to special:minimized"
        sleep 0.3 # let Hyprland settle before we start launching
    fi
}

# ---------------------------------------------------------------------------
# Extract workspace IDs from a layout JSON file
# ---------------------------------------------------------------------------

layout_workspaces() {
    # $1 = path to layout json
    jq -r '[.windows[].workspace_id] | unique[]' "$1"
}

# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------

action_load() {
    local layouts
    layouts="$(list_layouts)"

    if [[ -z "$layouts" ]]; then
        notify "No saved layouts found"
        exit 0
    fi

    local chosen
    chosen="$(echo "$layouts" | rofi -dmenu -i -p "Load layout" \
        -theme-str 'window {width: 500px;}')" || exit 0
    [[ -z "$chosen" ]] && exit 0

    local layout_file="$LAYOUTS_DIR/${chosen}.json"
    if [[ ! -f "$layout_file" ]]; then
        notify "Layout file not found: ${chosen}.json"
        exit 1
    fi

    notify "Loading '$chosen'…"

    # Collect workspace IDs this layout will use
    local -a ws_ids
    mapfile -t ws_ids < <(layout_workspaces "$layout_file")

    # Move existing windows on those workspaces out of the way
    stash_conflicting_windows "${ws_ids[@]}"

    # Launch the layout
    if python3 "$LAUNCH_PY" "$layout_file" --apps "$APPS_JSON"; then
        notify "Layout '$chosen' loaded"
    else
        notify "Failed to load '$chosen' — check terminal output"
        exit 1
    fi
}

action_save() {
    local name
    name="$(rofi -dmenu -p "Enter layout name" \
        -theme-str 'window {width: 400px;}')" || exit 0
    # Strip leading/trailing whitespace
    name="$(echo "$name" | xargs)"
    [[ -z "$name" ]] && exit 0

    local layout_file="$LAYOUTS_DIR/${name}.json"

    # Warn if overwriting
    if [[ -f "$layout_file" ]]; then
        local confirm
        confirm="$(printf "Yes, overwrite\nCancel" \
            | rofi -dmenu -i -p "Overwrite '$name'?" \
                -theme-str 'window {width: 400px;}' \
                -theme-str 'listview {lines: 2;}')" || exit 0
        [[ "$confirm" != "Yes, overwrite" ]] && exit 0
    fi

    notify "Capturing layout '$name'…"

    if python3 "$CAPTURE_PY" \
        --name "$name" \
        --output "$layout_file"; then
        notify "Layout '$name' saved"
    else
        notify "Failed to capture layout"
        exit 1
    fi
}

action_delete() {
    local layouts
    layouts="$(list_layouts)"

    if [[ -z "$layouts" ]]; then
        notify "No saved layouts found"
        exit 0
    fi

    local chosen
    chosen="$(echo "$layouts" | rofi -dmenu -i -p "Delete layout" \
        -theme-str 'window {width: 500px;}')" || exit 0
    [[ -z "$chosen" ]] && exit 0

    local confirm
    confirm="$(printf "Yes, delete\nCancel" \
        | rofi -dmenu -i -p "Delete '$chosen'?" \
            -theme-str 'window {width: 400px;}' \
            -theme-str 'listview {lines: 2;}')" || exit 0
    [[ "$confirm" != "Yes, delete" ]] && exit 0

    local layout_file="$LAYOUTS_DIR/${chosen}.json"
    if [[ ! -f "$layout_file" ]]; then
        notify "Layout not found: $chosen"
        exit 1
    fi

    rm "$layout_file"
    notify "Layout '$chosen' deleted"
}

# ---------------------------------------------------------------------------
# Main menu
# ---------------------------------------------------------------------------

main() {
    local action
    action="$(printf "📂 Load Saved Layout\n💾 Save Current Layout\n🗑️ Delete Layout" \
        | rofi -dmenu -i -p "Layout Manager" \
            -theme-str 'window {width: 420px;}' \
            -theme-str 'listview {lines: 3;}')" || exit 0

    case "$action" in
        "📂 Load Saved Layout") action_load ;;
        "💾 Save Current Layout") action_save ;;
        "🗑️ Delete Layout") action_delete ;;
        *) exit 0 ;;
    esac
}

main

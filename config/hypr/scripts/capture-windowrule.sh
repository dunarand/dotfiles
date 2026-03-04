#!/usr/bin/env bash

# Captures the focused window's properties from Hyprland and copies
# a windowrule snippet to the clipboard.

set -euo pipefail

for cmd in hyprctl jq wl-copy; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: '$cmd' is not installed or not in PATH." >&2
        exit 1
    fi
done

window_json=$(hyprctl activewindow -j 2>/dev/null)

if [[ -z "$window_json" || "$window_json" == "null" ]]; then
    echo "Error: No focused window found (is Hyprland running?)" >&2
    exit 1
fi

app_class=$(        jq -r '.class          // ""' <<< "$window_json")
app_title=$(        jq -r '.title          // ""' <<< "$window_json")
app_init_class=$(   jq -r '.initialClass   // ""' <<< "$window_json")
app_init_title=$(   jq -r '.initialTitle   // ""' <<< "$window_json")

snippet="windowrule {
    name = 
    match:class = ${app_class}
    match:title = ${app_title}
    match:initial_class = ${app_init_class}
    match:initial_title = ${app_init_title}
}"

printf '%s' "$snippet" | wl-copy

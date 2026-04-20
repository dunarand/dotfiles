#!/usr/bin/env bash
# Close the active window if it is floating
# Focuses to the current regular workspace if the floating

FLOATING=$(hyprctl activewindow -j | jq -r '.floating')
WORKSPACE=$(hyprctl activewindow -j | jq -r '.workspace.name')

if [[ "$WORKSPACE" == *"special"* ]]; then
    hyprctl dispatch workspace +0
    exit 0
fi

if [[ "$FLOATING" == "true" ]]; then
    hyprctl dispatch killactive
fi

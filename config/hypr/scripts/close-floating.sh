#!/usr/bin/env bash
# Close the active window if it is floating (intended for Escape key bind)

FLOATING=$(hyprctl activewindow -j | jq -r '.floating')

if [[ "$FLOATING" == "true" ]]; then
    hyprctl dispatch killactive
fi

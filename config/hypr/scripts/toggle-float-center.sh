#!/bin/sh

# Get active window address
WIN=$(hyprctl activewindow -j | jq -r '.address')
FLOATING=$(hyprctl -j clients | jq -r ".[] | select(.address == \"$WIN\") | .floating")

if [ "$FLOATING" = "false" ]; then
    # Window is tiled → float it, then resize + center
    hyprctl dispatch togglefloating
    sleep 0.05
    hyprctl dispatch resizeactive exact 60% 60%
    hyprctl dispatch centerwindow
else
    # Window is floating → simply return to tiling
    hyprctl dispatch togglefloating
fi

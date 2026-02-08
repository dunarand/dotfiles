#!/bin/bash
# Save as ~/.config/hypr/scripts/resize-toggle.sh

# Check if window is floating
is_floating=$(hyprctl activewindow -j | jq -r '.floating')

if [ "$is_floating" != "true" ]; then
    echo "Window is not floating"
    exit 1
fi

# Get current window size and monitor dimensions
window_info=$(hyprctl activewindow -j)
monitor_info=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true)')

current_width=$(echo "$window_info" | jq -r '.size[0]')
monitor_width=$(echo "$monitor_info" | jq -r '.width')

# Calculate current percentage
percentage=$((current_width * 100 / monitor_width))

# Toggle between 40 / 60 / 80% with tolerance thresholds
if [ $percentage -le 50 ]; then
    # Currently ~40% or less → switch to 60%
    hyprctl dispatch resizeactive exact 60% 60%
elif [ $percentage -le 70 ]; then
    # Currently ~60% → switch to 80%
    hyprctl dispatch resizeactive exact 80% 80%
else
    # Currently ~80% or more → switch to 40%
    hyprctl dispatch resizeactive exact 40% 40%
fi

# Center the window after resizing
hyprctl dispatch centerwindow

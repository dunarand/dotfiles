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

# Toggle between sizes with better tolerance
if [ $percentage -le 35 ]; then
    # Currently ~30% or less, switch to 50%
    hyprctl dispatch resizeactive exact 50% 50%
elif [ $percentage -le 60 ]; then
    # Currently ~50%, switch to 70%
    hyprctl dispatch resizeactive exact 70% 70%
else
    # Currently ~70% or more, switch to 30%
    hyprctl dispatch resizeactive exact 30% 30%
fi

# Center the window after resizing
hyprctl dispatch centerwindow

#!/bin/bash

TIMER_FILE="$HOME/.cache/wallpaper_autotimer"
SCRIPT="$HOME/.config/hypr/scripts/wallpaper-switch.sh"

# If timer exists → kill it
if [[ -f "$TIMER_FILE" ]]; then
    pid=$(cat "$TIMER_FILE")
    if kill "$pid" 2> /dev/null; then
        rm "$TIMER_FILE"
        notify-send "Auto Wallpaper" "Disabled"
        exit 0
    fi
fi

# Otherwise start auto timer
{
    while true; do
        $SCRIPT
        sleep 900 # Do not forget to update the notification at 5j
    done
} &

echo $! > "$TIMER_FILE"
notify-send "Auto Wallpaper" "Enabled (15m)"

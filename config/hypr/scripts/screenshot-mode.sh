#!/bin/bash

if pgrep -x slurp > /dev/null; then
    pkill -x slurp
    exit
fi

(
    sel=$(slurp) || exit
    f="$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
    grim -g "$sel" "$f"
    wl-copy < "$f"
    notify-send -r 999 -u low -i "$f" "Area screenshot copied" "$f"
) &

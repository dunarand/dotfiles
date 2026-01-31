#!/bin/bash

WINDOW="mixer"

# Kill any existing autoclose timers
pkill -f autoclose_mixer.sh

# If mixer is currently open → close it
if eww active-windows | grep -q "^${WINDOW}:"; then
    eww close "$WINDOW"
    exit 0
fi

# Otherwise open it
eww open "$WINDOW"
~/.config/eww/scripts/autoclose_mixer.sh &

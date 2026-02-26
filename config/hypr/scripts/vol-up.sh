#!/usr/bin/env bash

SINK="@DEFAULT_AUDIO_SINK@"

# If muted, unmute first
if wpctl get-volume $SINK | grep -q "MUTED"; then
    wpctl set-mute $SINK 0
fi

# Raise volume
wpctl set-volume $SINK 1%+ --limit 1.0

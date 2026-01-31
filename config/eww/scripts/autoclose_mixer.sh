#!/bin/bash

START_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

while true; do
    sleep 0.1

    CURRENT_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

    # If active window changed → start countdown
    if [ "$CURRENT_WINDOW" != "$START_WINDOW" ]; then
        sleep 1

        # Check again after delay
        CONFIRM_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

        if [ "$CONFIRM_WINDOW" != "$START_WINDOW" ]; then
            eww close mixer
            exit 0
        fi
    fi
done

START_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

while true; do
    sleep 0.1

    CURRENT_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

    # If active window changed → start countdown
    if [ "$CURRENT_WINDOW" != "$START_WINDOW" ]; then
        sleep 1

        # Check again after delay
        CONFIRM_WINDOW=$(hyprctl activewindow -j | jq -r '.address')

        if [ "$CONFIRM_WINDOW" != "$START_WINDOW" ]; then
            eww close mixer
            exit 0
        fi
    fi
done

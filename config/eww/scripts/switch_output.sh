#!/bin/bash

# Get list of sinks (descriptions) and their internal names
# We use Rofi to let the user pick the description, then map it back to the name
selection=$(pactl list sinks | grep 'Description:' | cut -d: -f2- | xargs | rofi -dmenu -p "Select Output" -config ~/.config/rofi/config.rasi)

if [ ! -z "$selection" ]; then
    # Find the internal name that matches the selected description
    target=$(pactl list sinks | grep -B 20 "Description: $selection" | grep "Name:" | awk '{print $2}')
    pactl set-default-sink "$target"
fi

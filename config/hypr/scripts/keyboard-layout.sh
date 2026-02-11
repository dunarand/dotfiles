#!/bin/bash

KEYBOARD="royuan-gaming-keyboard"

# Switch to next layout
hyprctl switchxkblayout "$KEYBOARD" next

# Get updated keymap name
LAYOUT=$(hyprctl devices -j | jq -r '
  .keyboards[]
  | select(.name=="'"$KEYBOARD"'")
  | .active_keymap
')

notify-send "Keyboard Layout" "$LAYOUT"

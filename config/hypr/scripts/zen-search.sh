#!/usr/bin/env bash

CURRENT_WS=$(hyprctl activeworkspace -j | jq '.id')

ZEN_ADDR=$(hyprctl clients -j | jq -r \
    ".[] | select(.class == \"zen\" and .workspace.id == $CURRENT_WS) | .address" \
    | head -n 1)

if [[ -n "$ZEN_ADDR" ]]; then
    # focus existing Zen window
    hyprctl dispatch focuswindow "address:$ZEN_ADDR"

    # open new tab in the SAME instance
    zen-browser --new-tab "https://duckduckgo.com/?t=h_&q="
else
    # no Zen on this workspace → open normally
    zen-browser
fi

#!/bin/bash

CURRENT=$(
    hyprctl devices -j |
        jq -r '.keyboards[] | .active_keymap' |
        head -n1 |
        cut -c1-2 |
        tr 'a-z' 'A-Z'
)

# Decide next layout
if [ "$CURRENT" = "EN" ]; then
    NEXT="tr"
else
    NEXT="us"
fi

hyprctl keyword input:kb_layout "$NEXT"

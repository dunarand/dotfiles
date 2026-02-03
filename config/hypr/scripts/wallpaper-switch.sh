#!/bin/bash

DIR="$HOME/Pictures/wallpapers"
FILES=("$DIR"/*.jpg "$DIR"/*.png)

CACHE="$HOME/.cache/swww_index"

# Read index, default to 0 if unreadable
INDEX=$(cat "$CACHE" 2>/dev/null)
[[ "$INDEX" =~ ^[0-9]+$ ]] || INDEX=0

((INDEX++))
if (( INDEX >= ${#FILES[@]} )); then
    INDEX=0
fi

echo "$INDEX" > "$CACHE"

SELECTED="${FILES[$INDEX]}"

swww img "$SELECTED" \
    --transition-type simple \
    --transition-step 10 \
    --resize crop

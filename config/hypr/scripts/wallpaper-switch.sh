#!/bin/bash

BASE="$HOME/Pictures/wallpapers"

MOOD_FILE="$HOME/.cache/wallpaper_mood"
INDEX_FILE="$HOME/.cache/wallpaper_index"

# Load mood
MOODS=("$BASE"/*/)
[[ -f "$MOOD_FILE" ]] && CURRENT_MOOD_INDEX=$(cat "$MOOD_FILE") || CURRENT_MOOD_INDEX=0
CURRENT_MOOD="${MOODS[$CURRENT_MOOD_INDEX]}"

# List files in mood
FILES=("$CURRENT_MOOD"*.jpg "$CURRENT_MOOD"*.png)
COUNT=${#FILES[@]}

[[ $COUNT -eq 0 ]] && notify-send "No wallpapers!" "Folder has no images." && exit 1

# Load index
[[ -f "$INDEX_FILE" ]] && INDEX=$(cat "$INDEX_FILE") || INDEX=0

# Advance
((INDEX++))
((INDEX >= COUNT)) && INDEX=0
echo "$INDEX" > "$INDEX_FILE"

# Apply wallpaper
swww img "${FILES[$INDEX]}" \
    --transition-type simple \
    --transition-step 10 \
    --resize crop

# Notify
NAME=$(basename "$CURRENT_MOOD")
FILE=$(basename "${FILES[$INDEX]}")

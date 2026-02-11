#!/bin/bash

BASE="$HOME/Pictures/wallpapers"

MOOD_FILE="$HOME/.cache/wallpaper_mood"
INDEX_FILE="$HOME/.cache/wallpaper_index"

MOODS=("$BASE"/*/)
TOTAL=${#MOODS[@]}

[[ -f "$MOOD_FILE" ]] && MOOD_INDEX=$(cat "$MOOD_FILE") || MOOD_INDEX=0

((MOOD_INDEX++))
((MOOD_INDEX >= TOTAL)) && MOOD_INDEX=0
echo "$MOOD_INDEX" > "$MOOD_FILE"

# Reset wallpaper index for new mood
echo 0 > "$INDEX_FILE"

NAME=$(basename "${MOODS[$MOOD_INDEX]}")
notify-send "Wallpaper mood changed" "Now using: $NAME"

# Immediately switch wallpaper
~/.config/hypr/scripts/wallpaper-switch.sh

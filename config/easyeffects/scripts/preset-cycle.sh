#!/usr/bin/env bash

PRESET_DIR="$HOME/Documents/easyeffects"
STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/easyeffects_preset_index"

mkdir -p "$(dirname "$STATE_FILE")"

mapfile -t PRESETS < <(
    find "$PRESET_DIR" -maxdepth 1 -type f -name '*.json' \
        | sed 's|.*/||; s|\.json$||' \
        | grep -vi '^mic' \
        | sort
)

if [ "${#PRESETS[@]}" -eq 0 ]; then
    notify-send "EasyEffects" "No output presets found"
    exit 1
fi

# Initialize state
if [ ! -f "$STATE_FILE" ]; then
    echo -1 > "$STATE_FILE"
fi

IDX=$(cat "$STATE_FILE")

# Sanity check
if ! [[ "$IDX" =~ ^-?[0-9]+$ ]]; then
    IDX=-1
fi

# Advance index FIRST
IDX=$(((IDX + 1) % ${#PRESETS[@]}))

PRESET="${PRESETS[$IDX]}"

# Load preset
easyeffects -l "$PRESET"

# Save state
echo "$IDX" > "$STATE_FILE"

# Notify
notify-send "EasyEffects" "Preset switched to: $PRESET"

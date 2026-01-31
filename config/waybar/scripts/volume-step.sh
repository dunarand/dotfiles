#!/usr/bin/env bash

TARGET="$1" # @DEFAULT_SINK@ or @DEFAULT_SOURCE@
DIR="$2"    # up or down
STEP=0.02  # 2%

# get current volume (0.0–1.0)
CUR=$(wpctl get-volume "$TARGET" | grep -oE '[0-9]+\.[0-9]+' | head -n1)

# fallback
[[ -z "$CUR" ]] && CUR=0.0

if [[ "$DIR" == "up" ]]; then
    NEW=$(awk "BEGIN {
        v=$CUR+$STEP;
        if (v>1) v=1;
        print v
    }")
else
    NEW=$(awk "BEGIN {
        v=$CUR-$STEP;
        if (v<0) v=0;
        print v
    }")
fi

wpctl set-volume "$TARGET" "$NEW"

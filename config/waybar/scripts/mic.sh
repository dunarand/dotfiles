#!/usr/bin/env bash

SOURCE="@DEFAULT_SOURCE@"
OUT=$(wpctl get-volume "$SOURCE")

VOL=$(echo "$OUT" | grep -oE '[0-9]+\.[0-9]+' | head -n1)
VOL=$(awk "BEGIN { printf \"%d\", $VOL * 100 }")

ICON=""
CLASS=""

if echo "$OUT" | grep -q MUTED; then
    ICON=""
    CLASS="muted"
fi

NAME=$(wpctl inspect "$SOURCE" | grep -m1 "node.description" | cut -d '"' -f2)

echo "{\"text\":\"$ICON $VOL%\",\"tooltip\":\"$NAME\",\"class\":\"$CLASS\"}"

#!/usr/bin/env bash

mapfile -t MACS < <(bluetoothctl devices Connected | awk '{print $2}')

if [ ${#MACS[@]} -eq 0 ]; then
    echo "No connected devices"
    exit 0
fi

for MAC in "${MACS[@]}"; do
    INFO=$(bluetoothctl info "$MAC")

    NAME=$(echo "$INFO" | grep -m1 "Name:" | cut -d' ' -f2-)

    BATTERY=$(echo "$INFO" | grep -i "Battery Percentage" | grep -o '[0-9]\+')

    if [ -n "$BATTERY" ]; then
        echo "• $NAME: ${BATTERY}%"
    else
        echo "• $NAME"
    fi
done

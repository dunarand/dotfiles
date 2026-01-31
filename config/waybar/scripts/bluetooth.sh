#!/usr/bin/env bash

# Bluetooth power check
if ! bluetoothctl show | grep -q "Powered: yes"; then
    printf '{"text":"󰂲","tooltip":"Bluetooth off"}\n'
    exit 0
fi

# Use BlueZ's authoritative connected list
mapfile -t DEVICES < <(bluetoothctl devices Connected)

if [ ${#DEVICES[@]} -eq 0 ]; then
    printf '{"text":"","tooltip":"No connected devices"}\n'
    exit 0
fi

TOOLTIP=""
COUNT=0

for LINE in "${DEVICES[@]}"; do
    MAC=$(echo "$LINE" | awk '{print $2}')
    NAME=$(echo "$LINE" | cut -d' ' -f3-)

    INFO=$(bluetoothctl info "$MAC")

    BATTERY=$(echo "$INFO" \
        | grep "Battery Percentage" \
        | sed -n 's/.*(\([0-9]\+\)).*/\1/p')

    if [ -n "$BATTERY" ]; then
        TOOLTIP+="• $NAME: ${BATTERY}%\n"
    else
        TOOLTIP+="• $NAME\n"
    fi

    COUNT=$((COUNT + 1))
done

TOOLTIP=${TOOLTIP%$'\n'}

printf '{"text":" %d","tooltip":"%s"}\n' "$COUNT" "$TOOLTIP"

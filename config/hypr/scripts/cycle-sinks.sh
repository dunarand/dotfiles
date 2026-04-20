#!/usr/bin/env bash

# Get list of sinks
sinks=($(pactl list short sinks | awk '{print $2}'))

# Get current default sink
current=$(pactl info | grep "Default Sink" | awk '{print $3}')

# Find current index
for i in "${!sinks[@]}"; do
    if [[ "${sinks[$i]}" == "$current" ]]; then
        next=$(((i + 1) % ${#sinks[@]}))
        break
    fi
done

new_sink=${sinks[$next]}

# Switch default sink
pactl set-default-sink "$new_sink"

# Move all streams to the new sink
pactl list short sink-inputs | awk '{print $1}' \
    | xargs -I{} pactl move-sink-input {} "$new_sink"

desc=$(pactl list sinks | awk -v sink="$new_sink" '
$0 ~ "Name: "sink {found=1}
found && /Description:/ {sub("Description: ", ""); print; exit}
')

notify-send -h string:x-canonical-private-synchronous:audio-switch \
            -h int:transient:1 \
            "Audio Output Switched: $desc"

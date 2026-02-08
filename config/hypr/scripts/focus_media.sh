#!/bin/bash
# Get the first active audio stream from PipeWire
STREAM=$(wpctl status | awk '
    /└─ Streams:/{in_streams=1; next}
    /^[A-Z]/{in_streams=0}
    in_streams && /^[[:space:]]+[0-9]+\. [a-zA-Z]/ && !/input_|monitor_|output_/ {
        stream_name=$0
        gsub(/^[[:space:]]*[0-9]+\. /, "", stream_name)
        getline
        if ($0 ~ /output_.*\[active\]/) {
            print stream_name
            exit
        }
    }
' | xargs)

if [[ -z "$STREAM" ]]; then
    notify-send "No active audio stream"
    exit 1
fi

# Handle cases where PipeWire name differs from window class
NORMALIZED=$(echo "$STREAM" | tr '[:upper:]' '[:lower:]')
case "$NORMALIZED" in
    *vlc* | *libvlc*)
        MATCH="vlc"
        ;;
    *chrome* | *chromium*)
        MATCH="chromium|google-chrome|brave|chrome"
        ;;
    *)
        # Default: use stream name as-is
        MATCH="$STREAM"
        ;;
esac

# Find window in Hyprland (case-insensitive match)
CLIENT=$(hyprctl clients -j | jq -r ".[] | select(.class | test(\"$MATCH\"; \"i\"))")

if [[ -z "$CLIENT" ]]; then
    notify-send "Audio source '$STREAM' found but no matching window."
    exit 1
fi

# Get window address + workspace
ADDR=$(echo "$CLIENT" | jq -r '.address')
WS=$(echo "$CLIENT" | jq -r '.workspace.id')

# Switch to its workspace and focus it
hyprctl dispatch workspace "$WS"
hyprctl dispatch focuswindow "address:$ADDR"

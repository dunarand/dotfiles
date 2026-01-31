#!/usr/bin/env bash

PLAYER_ARGS="--player=playerctld"

# ---- TOGGLE ----
if pgrep -x rofi > /dev/null; then
    pkill rofi
    exit 0
fi

# Exit if no MPRIS player
playerctl $PLAYER_ARGS status &> /dev/null || exit 0

TITLE=$(playerctl $PLAYER_ARGS metadata title 2> /dev/null)
ARTIST=$(playerctl $PLAYER_ARGS metadata artist 2> /dev/null)
PLAYER_NAME=$(playerctl $PLAYER_ARGS metadata --format '{{playerName}}' 2> /dev/null)

STATUS=$(playerctl $PLAYER_ARGS status 2> /dev/null)
LOOP=$(playerctl $PLAYER_ARGS loop 2> /dev/null)
SHUFFLE=$(playerctl $PLAYER_ARGS shuffle 2> /dev/null)

# Label
if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
    LABEL="$ARTIST — $TITLE"
elif [ -n "$TITLE" ]; then
    LABEL="$TITLE"
elif [ -n "$PLAYER_NAME" ]; then
    LABEL="$PLAYER_NAME"
else
    LABEL="Nothing playing"
fi

[ "$STATUS" = "Playing" ] && TOGGLE="  Pause" || TOGGLE="  Play"

case "$LOOP" in
    Track) LOOP_LABEL="  Repeat track" ;;
    Playlist) LOOP_LABEL="  Repeat playlist" ;;
    *) LOOP_LABEL="  Repeat off" ;;
esac

[ "$SHUFFLE" = "On" ] && SHUFFLE_LABEL="  Shuffle on" || SHUFFLE_LABEL="  Shuffle off"

choice=$(
    printf "%s\n󰒮  Previous\n󰒭  Next\n  Stop\n\n%s\n%s" \
        "$TOGGLE" "$SHUFFLE_LABEL" "$LOOP_LABEL" \
        | rofi -dmenu \
            -theme media-controller \
            -p "󰎆  $LABEL"
)

case "$choice" in
    *Pause* | *Play*) playerctl $PLAYER_ARGS play-pause ;;
    *Previous*) playerctl $PLAYER_ARGS previous ;;
    *Next*) playerctl $PLAYER_ARGS next ;;
    *Stop*) playerctl $PLAYER_ARGS stop ;;
    *Shuffle*) playerctl $PLAYER_ARGS shuffle toggle ;;
    *Repeat*)
        case "$LOOP" in
            None) playerctl $PLAYER_ARGS loop Track ;;
            Track) playerctl $PLAYER_ARGS loop Playlist ;;
            Playlist) playerctl $PLAYER_ARGS loop None ;;
        esac
        ;;
esac

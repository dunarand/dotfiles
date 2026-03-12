#!/usr/bin/env bash
# cliphist-rofi.sh — clipboard history with inline delete keybinds
# Keybinds in the rofi menu:
#   Enter        → paste selected
#   Alt+D        → delete selected entry (menu stays open)
#   Alt+Shift+D  → wipe all history (menu stays open)
#   Escape        → close

while true; do
    SELECTION=$(cliphist list | rofi -dmenu -p "Clipboard" \
        -kb-custom-1 "Alt+d" \
        -kb-custom-2 "Alt+a" \
        -mesg "Enter: paste  |  Alt+D: delete  |  Alt+A: wipe all")

    EXIT_CODE=$?

    case $EXIT_CODE in
        0) # Enter — paste and exit
            echo "$SELECTION" | cliphist decode | wl-copy
            break
            ;;
        10) # Alt+D — delete selected, reopen
            echo "$SELECTION" | cliphist delete
            ;;
        11) # Alt+Shift+D — wipe all, reopen
            CONFIRM=$(printf "No\nYes, wipe everything" | rofi -dmenu -p "Are you sure?")
            if [[ "$CONFIRM" == "Yes, wipe everything" ]]; then
                cliphist wipe
            fi
            ;;
        *) # Escape or anything else — exit
            break
            ;;
    esac
done

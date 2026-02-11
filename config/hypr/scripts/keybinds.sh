#!/bin/bash

HYPR_CONF="$HOME/.config/hypr/hyprland.conf"

declare -A KEY_GLYPHS=(
    ["SUPER"]=""
    ["CTRL"]="⌃"
    ["ALT"]="⌥"
    ["SHIFT"]="⇧"
    ["SPACE"]="󱁐"
    ["ESCAPE"]="󱊷"
    ["BACKSPACE"]="⌫"
    ["DELETE"]="⌦"
    ["TAB"]="󰌒"
    ["ENTER"]="󰌑"
    ["LEFT"]="←"
    ["RIGHT"]="→"
    ["UP"]="↑"
    ["DOWN"]="↓"
    ["F1"]="󱊫"
    ["F2"]="󱊬"
    ["F3"]="󱊭"
    ["F4"]="󱊮"
    ["F5"]="󱊯"
    ["F6"]="󱊰"
    ["F7"]="󱊱"
    ["F8"]="󱊲"
    ["F9"]="󱊳"
    ["F10"]="󱊴"
    ["F11"]="󱊵"
    ["F12"]="󱊶"
)

# Convert key names to glyphs
beautify_keys() {
    local input="${1/\$mainMod/SUPER}"
    local out=""

    for token in $input; do
        if [[ -n ${KEY_GLYPHS[$token]} ]]; then
            out+="${KEY_GLYPHS[$token]} "
        else
            out+="$token "
        fi
    done

    echo "${out% }"
}

# Trim leading and trailing whitespace
trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# Parse Hyprland variable definitions
declare -A HYPR_VARS

while IFS= read -r line; do
    if [[ $line =~ ^\$([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value=$(trim "${BASH_REMATCH[2]%%#*}")
        HYPR_VARS[$var_name]="$var_value"
    fi
done < "$HYPR_CONF"

# Expand Hyprland variables in command strings
expand_vars() {
    local str="$1"
    for var in "${!HYPR_VARS[@]}"; do
        str="${str//\$$var/${HYPR_VARS[$var]}}"
    done
    echo "$str"
}

# Parse keybindings
BINDINGS=()
COMMANDS=()

while IFS= read -r line; do
    [[ $line =~ ^bind ]] || continue

    # Skip lines with # ignore
    [[ $line =~ \#[[:space:]]*ignore ]] && continue

    # Extract description from comment
    desc=""
    if [[ $line == *"#"* ]]; then
        desc=$(trim "${line#*#}")
        line="${line%%#*}"
    fi

    # Remove bind prefix and parse fields
    line="${line#*=}"
    IFS=',' read -r mod key rest <<< "$line"

    mod=$(trim "$mod")
    key=$(trim "$key")
    rest=$(trim "$rest")

    [[ -z $rest ]] && continue

    # Convert commas to spaces and expand variables
    rest="${rest//,/ }"
    rest=$(expand_vars "$rest")

    # Store binding and command
    mod_b=$(beautify_keys "$mod")
    key_b=$(beautify_keys "$key")
    BINDINGS+=("${mod_b} + ${key_b}  ${desc:-No description}")
    COMMANDS+=("$rest")
done < "$HYPR_CONF"

# Display bindings in rofi
CHOICE=$(printf "%s\n" "${BINDINGS[@]}" | rofi -dmenu -i -p "Hyprland Keybinds")
[[ -z $CHOICE ]] && exit 0

# Find selected binding index
INDEX=-1
for i in "${!BINDINGS[@]}"; do
    if [[ ${BINDINGS[$i]} == "$CHOICE" ]]; then
        INDEX=$i
        break
    fi
done

[[ $INDEX -eq -1 ]] && exit 1

# Execute command
CMD="${COMMANDS[$INDEX]}"
[[ -z $CMD ]] && exit 0

if [[ $CMD == exec* ]]; then
    CMD=$(trim "${CMD#exec}")
    bash -c "$CMD" &
    disown
else
    hyprctl dispatch $CMD
fi

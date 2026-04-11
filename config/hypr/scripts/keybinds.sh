#!/bin/bash

HYPR_CONF="$HOME/.config/hypr/keybinds.conf"

# --- GLYPHS --------------------------------------------------

declare -A KEY_GLYPHS=(
    ["SUPER"]=""
    ["CTRL"]="󰘴"
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

beautify_keys() {
    local input="${1/\$mod/SUPER}"
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

trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# --- LOAD $VARS --------------------------------------------------

declare -A HYPR_VARS

# Load from *this* file
while IFS= read -r line; do
    if [[ $line =~ ^\$([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value=$(trim "${BASH_REMATCH[2]%%#*}")
        HYPR_VARS[$var_name]="$var_value"
    fi
done < "$HYPR_CONF"

# ALSO load from hyprland.conf (your program vars)
while IFS= read -r line; do
    if [[ $line =~ ^\$([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value=$(trim "${BASH_REMATCH[2]%%#*}")
        HYPR_VARS[$var_name]="$var_value"
    fi
done < "$HOME/.config/hypr/hyprland.conf"

expand_vars() {
    local str="$1"
    for var in "${!HYPR_VARS[@]}"; do
        str="${str//\$$var/${HYPR_VARS[$var]}}"
    done
    echo "$str"
}

# --- PARSE BINDINGS --------------------------------------------

BINDINGS=()
COMMANDS=()

while IFS= read -r raw; do
    [[ $raw =~ ^bindd ]] || [[ $raw =~ ^binddl ]] || continue

    # remove inline comments
    line="${raw%%#*}"

    # cut before '='
    line="${line#*=}"

    # split *all* comma fields into an array
    IFS=',' read -ra fields <<< "$line"
    for i in "${!fields[@]}"; do
        fields[$i]=$(trim "${fields[$i]}")
    done

    # must have at least 4 fields
    [[ ${#fields[@]} -ge 4 ]] || continue

    mod="${fields[0]}"
    key="${fields[1]}"
    desc="${fields[2]}"
    cmd="${fields[3]}"

    # args = EVERYTHING after field 3
    args="${fields[*]:4}"

    [[ -z $desc ]] && desc="No description"

    # pretty keys
    mod_b=$(beautify_keys "$mod")
    key_b=$(beautify_keys "$key")

    # expand vars
    cmd_expanded=$(expand_vars "$cmd")
    args_expanded=$(expand_vars "$args")

    BINDINGS+=("${mod_b} + ${key_b}  ${desc}")
    COMMANDS+=("$cmd_expanded|$args_expanded")

done < "$HYPR_CONF"

# --- SELECT ----------------------------------------------------

CHOICE=$(printf "%s\n" "${BINDINGS[@]}" | rofi -dmenu -i -p "Keybinds")
[[ -z $CHOICE ]] && exit 0

INDEX=-1
for i in "${!BINDINGS[@]}"; do
    [[ ${BINDINGS[$i]} == "$CHOICE" ]] && INDEX=$i && break
done

[[ $INDEX -eq -1 ]] && exit 1

# --- EXECUTE ---------------------------------------------------

CMD_RAW="${COMMANDS[$INDEX]}"

cmd="${CMD_RAW%%|*}"
args="${CMD_RAW#*|}"

cmd=$(trim "$cmd")
args=$(trim "$args")

# Hyprland exec MUST be run via hyprctl
if [[ $cmd == "exec" ]]; then
    hyprctl dispatch exec "$args"
else
    hyprctl dispatch "$cmd" "$args"
fi

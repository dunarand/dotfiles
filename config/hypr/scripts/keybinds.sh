#!/bin/bash
HYPR_CONF="$HOME/.config/hypr/keybinds.conf"
HYPR_MAIN="$HOME/.config/hypr/hyprland.conf"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
CACHE_FILE="$CACHE_DIR/keybinds.cache"
CACHE_MTIME="$CACHE_DIR/keybinds.mtime"

# --- CACHE HELPERS ---------------------------------------------
get_mtime() {
    stat -c '%Y' "$1" 2>/dev/null || echo 0
}

cache_is_valid() {
    [[ -f $CACHE_FILE && -f $CACHE_MTIME ]] || return 1
    local stored
    stored=$(cat "$CACHE_MTIME")
    local current
    current="$(get_mtime "$HYPR_CONF"):$(get_mtime "$HYPR_MAIN")"
    [[ $stored == "$current" ]]
}

write_cache() {
    mkdir -p "$CACHE_DIR"
    # Write entries as: BINDING<TAB>CMD|ARGS
    local i
    for i in "${!BINDINGS[@]}"; do
        printf '%s\t%s\n' "${BINDINGS[$i]}" "${COMMANDS[$i]}"
    done > "$CACHE_FILE"
    # Write mtime stamp
    echo "$(get_mtime "$HYPR_CONF"):$(get_mtime "$HYPR_MAIN")" > "$CACHE_MTIME"
}

load_cache() {
    BINDINGS=()
    COMMANDS=()
    while IFS=$'\t' read -r binding command; do
        BINDINGS+=("$binding")
        COMMANDS+=("$command")
    done < "$CACHE_FILE"
}

# --- GLYPHS ----------------------------------------------------
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
    ["mouse:272"]="󰍽󰬺"
    ["mouse:273"]="󰍽󰬻"
    ["mouse:274"]="󰍽󰬼"
    ["mouse:btn_side"]="󰍽󰬽"
    ["mouse:btn_extra"]="󰍽󰬾"
    ["mouse_up"]="󰍽↑"
    ["mouse_down"]="󰍽↓"
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

# --- LOAD $VARS ------------------------------------------------
declare -A HYPR_VARS

while IFS= read -r line; do
    if [[ $line =~ ^\$([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
        HYPR_VARS[${BASH_REMATCH[1]}]=$(trim "${BASH_REMATCH[2]%%#*}")
    fi
done < "$HYPR_CONF"

while IFS= read -r line; do
    if [[ $line =~ ^\$([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
        HYPR_VARS[${BASH_REMATCH[1]}]=$(trim "${BASH_REMATCH[2]%%#*}")
    fi
done < "$HYPR_MAIN"

expand_vars() {
    local str="$1"
    for var in "${!HYPR_VARS[@]}"; do
        str="${str//\$$var/${HYPR_VARS[$var]}}"
    done
    echo "$str"
}

# --- BINDINGS (parse or load cache) ----------------------------
BINDINGS=()
COMMANDS=()

if cache_is_valid; then
    load_cache
else
    while IFS= read -r raw; do
        [[ $raw =~ ^bindd ]] || [[ $raw =~ ^binddl ]] || continue
        line="${raw%%#*}"
        line="${line#*=}"
        IFS=',' read -ra fields <<< "$line"
        for i in "${!fields[@]}"; do
            fields[$i]=$(trim "${fields[$i]}")
        done
        [[ ${#fields[@]} -ge 4 ]] || continue

        mod="${fields[0]}"
        key="${fields[1]}"
        desc="${fields[2]}"
        cmd="${fields[3]}"
        args="${fields[*]:4}"

        [[ -z $desc ]] && desc="No description"

        mod_b=$(beautify_keys "$mod")
        key_b=$(beautify_keys "$key")
        cmd_expanded=$(expand_vars "$cmd")
        args_expanded=$(expand_vars "$args")

        BINDINGS+=("${mod_b} + ${key_b}  ${desc}")
        COMMANDS+=("$cmd_expanded|$args_expanded")
    done < "$HYPR_CONF"

    write_cache
fi

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

if [[ $cmd == "exec" ]]; then
    hyprctl dispatch exec "$args"
else
    hyprctl dispatch "$cmd" "$args"
fi

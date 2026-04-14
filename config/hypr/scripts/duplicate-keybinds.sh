#!/bin/bash

HYPR_CONF="$HOME/.config/hypr/keybinds.conf"

trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# --- LOAD VARIABLES ------------------------------------------

declare -A HYPR_VARS

load_vars() {
    local file="$1"
    [[ -f $file ]] || return
    while IFS= read -r line; do
        if [[ $line =~ ^\$([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            var_name="${BASH_REMATCH[1]}"
            var_value=$(trim "${BASH_REMATCH[2]%%#*}")
            HYPR_VARS[$var_name]="$var_value"
        fi
    done < "$file"
}

load_vars "$HYPR_CONF"
load_vars "$HOME/.config/hypr/hyprland.conf"

expand_vars() {
    local str="$1"
    for var in "${!HYPR_VARS[@]}"; do
        str="${str//\$$var/${HYPR_VARS[$var]}}"
    done
    echo "$str"
}

# --- NORMALIZE MODIFIERS -------------------------------------

normalize_mods() {
    local mods="$1"

    # split → sort → join
    read -ra parts <<< "$mods"
    IFS=$'\n' sorted=($(sort <<< "${parts[*]}"))
    unset IFS

    echo "${sorted[*]}"
}

# --- DETECT DUPLICATES ---------------------------------------

declare -A SEEN
declare -A DUPES

while IFS= read -r raw; do
    [[ $raw =~ ^bind ]] || continue

    line="${raw%%#*}"
    line="${line#*=}"

    IFS=',' read -ra fields <<< "$line"
    for i in "${!fields[@]}"; do
        fields[$i]=$(trim "${fields[$i]}")
    done

    [[ ${#fields[@]} -ge 2 ]] || continue

    mod=$(expand_vars "${fields[0]}")
    key=$(expand_vars "${fields[1]}")

    # normalize modifier order
    mod_norm=$(normalize_mods "$mod")

    combo="$mod_norm + $key"

    if [[ -n ${SEEN[$combo]} ]]; then
        DUPES["$combo"]+=$'\n'"  → $raw"
    else
        SEEN["$combo"]="$raw"
    fi

done < "$HYPR_CONF"

# --- OUTPUT --------------------------------------------------

if [[ ${#DUPES[@]} -eq 0 ]]; then
    echo "No duplicate keybinds found ✅"
    exit 0
fi

echo "Duplicate keybinds found:"
echo

for combo in "${!DUPES[@]}"; do
    echo "$combo"
    echo "  → ${SEEN[$combo]}"
    echo "${DUPES[$combo]}"
    echo
done

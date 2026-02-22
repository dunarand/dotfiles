#!/usr/bin/env bash
set -e

SESSIONS_DIR="$HOME/.config/hyprdrover/sessions"
mkdir -p "$SESSIONS_DIR"

if ! command -v hyprdrover &> /dev/null; then
    notify-send "Error" "hyprdrover not found" -u critical
    exit 1
fi

resolve_exec() {
    cls="$1"
    cls_lc="$(echo "$cls" | tr 'A-Z' 'a-z')"

    candidates=()
    candidates+=("$cls_lc")
    cls_clean="$(echo "$cls_lc" | tr -cd 'a-z0-9_-')"
    candidates+=("$cls_clean")
    candidates+=("${cls_clean%-default}")
    candidates+=("${cls_clean%-stable}")
    candidates+=("${cls_clean%-beta}")
    candidates+=("${cls_clean}-stable")
    candidates+=("${cls_clean}-browser")
    candidates+=("${cls_clean}-desktop")

    candidates=($(printf "%s\n" "${candidates[@]}" | awk '!seen[$0]++'))

    for c in "${candidates[@]}"; do
        bin="$(which "$c" 2> /dev/null || true)"
        [[ -n "$bin" ]] && echo "$bin" && return 0
    done

    mapfile -t found < <(compgen -c | grep -i "$cls_clean" | sort -u)
    for f in "${found[@]}"; do
        bin="$(which "$f" 2> /dev/null || true)"
        [[ -n "$bin" ]] && echo "$bin" && return 0
    done

    echo ""
}

sanitize_exec_paths() {
    file="$1"
    tmp=$(mktemp)

    jq -r '.clients[].class' "$file" | while read -r cls; do
        exec="$(resolve_exec "$cls")"
        [[ -n "$exec" ]] && echo "$cls|$exec"
    done \
        | while IFS="|" read -r cls exec; do
            jq --arg cls "$cls" --arg exec "$exec" \
                '
            .clients |= map(
                if .class == $cls then
                    .execPath = $exec
                else . end
            )
            ' "$file" > "$tmp" && mv "$tmp" "$file"
        done
}

show_main_menu() {
    printf "💾 Save Current Layout\n📂 Load Saved Layout\n🗑️ Delete Layout" \
        | rofi -dmenu -i -p "Layout Manager" \
            -theme-str 'window {width: 420px;}' \
            -theme-str 'listview {lines: 3;}'
}

select_layout() {
    ls "$SESSIONS_DIR"/*.json 2> /dev/null | xargs -n1 basename | sed 's/.json$//'
}

save_layout() {
    layout_name=$(rofi -dmenu -p "Enter layout name" -theme-str 'window {width: 400px;}')
    [[ -z "$layout_name" ]] && notify-send "Cancelled" "Save cancelled" && exit 0

    if hyprdrover --save "$layout_name"; then
        json="$SESSIONS_DIR/${layout_name}.json"
        sanitize_exec_paths "$json"
        notify-send "Layout Saved" "'$layout_name' saved"
    else
        notify-send "Error" "Could not save '$layout_name'" -u critical
    fi
}

load_layout() {
    list=$(select_layout)
    [[ -z "$list" ]] && notify-send "No Layouts" "No layouts saved" && exit 0

    selected=$(echo "$list" | rofi -dmenu -i -p "Load layout" -theme-str 'window {width: 500px;}')
    [[ -z "$selected" ]] && notify-send "Cancelled" "Load cancelled" && exit 0

    if hyprdrover --load "$selected"; then
        notify-send "Layout Loaded" "'$selected' loaded"
    else
        notify-send "Error" "Could not load '$selected'" -u critical
    fi
}

delete_layout() {
    list=$(select_layout)
    [[ -z "$list" ]] && notify-send "No Layouts" "No layouts saved" && exit 0

    selected=$(echo "$list" | rofi -dmenu -i -p "Delete layout" -theme-str 'window {width: 500px;}')
    [[ -z "$selected" ]] && notify-send "Cancelled" "Delete cancelled" && exit 0

    file="$SESSIONS_DIR/${selected}.json"
    rm -f "$file"

    notify-send "Layout Deleted" "'$selected' removed"
}

choice="$(show_main_menu)"

case "$choice" in
    "💾 Save Current Layout") save_layout ;;
    "📂 Load Saved Layout") load_layout ;;
    "🗑️ Delete Layout") delete_layout ;;
    *) exit 0 ;;
esac

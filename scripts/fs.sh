#!/bin/bash
set -euo pipefail

CWD="$(pwd)"
HOME_DIR="$HOME"

DIRS=()
USE_HOME_FILTER=false

##############################################################
# DETECT WHETHER WE'RE RUNNING FROM $HOME
##############################################################
if [[ "$CWD" == "$HOME_DIR" ]]; then
    USE_HOME_FILTER=true
fi


##############################################################
# MODE SELECTION (same as before)
##############################################################
MODE=$(printf "Files\nRipgrep" | fzf --prompt="Choose mode: " --height=20%)
[[ -z "$MODE" ]] && exit 0


##############################################################
# BUILD DIRECTORY LIST
##############################################################

if [[ "$USE_HOME_FILTER" == true ]]; then
    # --- SPECIAL HOME LOGIC ---
    # include: non-dot dirs + .config
    while IFS= read -r -d '' item; do
        base=$(basename "$item")
        if [[ "$base" == ".config" ]] || [[ "$base" != .* ]]; then
            DIRS+=("$item")
        fi
    done < <(find "$HOME_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

else
    # --- SIMPLE LOGIC: index ENTIRE current directory ---
    DIRS+=("$CWD")
fi


##############################################################
# FILE PICKER (fd)
##############################################################
if [[ "$MODE" == "Files" ]]; then

    FD_CMD=(fd --type f --hidden --follow \
             --exclude .git \
             --exclude .cache \
             --exclude node_modules)

    # Correct way to pass directories
    for d in "${DIRS[@]}"; do
        FD_CMD+=(--search-path "$d")
    done

    "${FD_CMD[@]}" | \
    fzf --layout=reverse --border \
        --preview 'bat --style=numbers --color=always --line-range :300 {}' \
        --bind 'enter:become(xdg-open {+})' \
        --bind 'ctrl-v:become(xdg-open {+})' \
        --bind 'ctrl-s:become(xdg-open {+})'

    exit 0
fi


##############################################################
# RIPGREP (rg)
##############################################################
if [[ "$MODE" == "Ripgrep" ]]; then

    # Prepare dirs for fzf reload safely
    DIRS_QUOTED=""
    for d in "${DIRS[@]}"; do
        DIRS_QUOTED+=" $(printf "%q" "$d")"
    done

    fzf --ansi --phony --delimiter ':' --prompt 'rg> ' \
        --bind "change:reload:rg --line-number --no-heading --color=always {q} $DIRS_QUOTED || true" \
        --preview 'bat --style=numbers --color=always {1} --highlight-line {2}' \
        --bind 'enter:become(xdg-open {1})'

    exit 0
fi

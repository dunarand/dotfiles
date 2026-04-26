#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

confirm() {
    local name="$1"
    read -rp "Proceed with $name? [Y/n] " ans
    [[ "$ans" =~ ^[Nn]$ ]] && return 1 || return 0
}

read_packages() {
    grep -vE '^\s*(#|$)' "$1"
}

echo "=== PACMAN INSTALL ==="

# 1. pacman-needed.txt
FILE="$SCRIPT_DIR/pacman-needed.txt"
if [[ -f "$FILE" ]] && confirm "pacman-needed.txt"; then
    mapfile -t pkgs < <(read_packages "$FILE")
    if (( ${#pkgs[@]} )); then
        sudo pacman -S --needed --noconfirm "${pkgs[@]}"
    fi
fi

# 2. pacman.txt
FILE="$SCRIPT_DIR/pacman.txt"
if [[ -f "$FILE" ]] && confirm "pacman.txt"; then
    mapfile -t pkgs < <(read_packages "$FILE")
    if (( ${#pkgs[@]} )); then
        sudo pacman -S "${pkgs[@]}"
    fi
fi

echo "=== AUR INSTALL ==="

# 3. aur.txt (yay)
FILE="$SCRIPT_DIR/aur.txt"
if command -v yay &>/dev/null && [[ -f "$FILE" ]] && confirm "aur.txt"; then
    mapfile -t pkgs < <(read_packages "$FILE")
    if (( ${#pkgs[@]} )); then
        yay -S --needed "${pkgs[@]}"
    fi
else
    [[ ! -x "$(command -v yay)" ]] && echo "[skip] yay not installed"
fi

# 4. flatpak.txt (platpak)
FILE="$SCRIPT_DIR/flatpak.txt"
if command -v flatpak &>/dev/null && [[ -f "$FILE" ]] && confirm "flatpak.txt"; then
    mapfile -t pkgs < <(read_packages "$FILE")
    if (( ${#pkgs[@]} )); then
        flatpak install flathub "${pkgs[@]}"
    fi
else
    [[ ! -x "$(command -v flatpak)" ]] && echo "[skip] flatpak not installed"
fi

echo "=== OTHER SOURCES ==="

# npm
FILE="$SCRIPT_DIR/npm.txt"
if command -v npm &>/dev/null && [[ -f "$FILE" ]] && confirm "npm.txt"; then
    mapfile -t pkgs < <(read_packages "$FILE")
    for p in "${pkgs[@]}"; do
        sudo npm install -g "$p"
    done
fi

# pip via uv
FILE="$SCRIPT_DIR/pip.txt"
if command -v uv &>/dev/null && [[ -f "$FILE" ]] && confirm "pip.txt (uv)"; then
    mapfile -t pkgs < <(read_packages "$FILE")
    for p in "${pkgs[@]}"; do
        uv tool install "$p"
    done
fi

# go
FILE="$SCRIPT_DIR/go.txt"
if command -v go &>/dev/null && [[ -f "$FILE" ]] && confirm "go.txt"; then
    mapfile -t pkgs < <(read_packages "$FILE")
    for p in "${pkgs[@]}"; do
        go install "$p"
    done
fi

# cargo
FILE="$SCRIPT_DIR/cargo.txt"
if command -v cargo &>/dev/null && [[ -f "$FILE" ]] && confirm "cargo.txt"; then
    mapfile -t pkgs < <(read_packages "$FILE")
    for p in "${pkgs[@]}"; do
        cargo install "$p"
    done
fi

echo "=== DONE ==="

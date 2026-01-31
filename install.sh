#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}Installing dotfiles from ${DOTFILES_DIR}${NC}"

ask_confirmation() {
    local prompt=$1
    while true; do
        read -p "$(echo -e ${BLUE}${prompt}${NC} [y/n]:)" yn
        case $yn in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo -e "${YELLOW}Please answer yes or no.${NC}" ;;
        esac
    done
}

create_symlink() {
    local source=$1
    local target=$2

    mkdir -p "$(dirname "$target")"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo -e "${YELLOW}Backing up existing $target to $target.backup${NC}"
        mv "$target" "$target.backup"
    fi

    if [ -L "$target" ]; then
        rm "$target"
    fi

    ln -s "$source" "$target"
    echo -e "${GREEN}✓${NC} Linked $source -> $target"
}

# -------------------------------
# Script permission handling
# -------------------------------

chmod_script_if_valid() {
    local file="$1"

    if head -n 1 "$file" | grep -q "^#\!"; then
        chmod +x "$file"
        echo -e "${GREEN}✓${NC} chmod +x $file"
    else
        echo -e "${YELLOW}! Skipped (no shebang): $file${NC}"
    fi
}

handle_config_scripts_permissions() {
    local config_dir="$DOTFILES_DIR/config"

    [ ! -d "$config_dir" ] && return

    echo -e "\n${BLUE}How should script permissions under config/ be handled?${NC}"
    echo "1) Automatically make all scripts executable"
    echo "2) Prompt per directory"
    echo "3) Prompt per individual script"
    echo "4) Skip"

    read -p "Select an option [1-4]: " choice

    case "$choice" in
        1)
            echo -e "\n${GREEN}Making all config scripts executable...${NC}"
            find "$config_dir" -type f -name "*.sh" | while read -r file; do
                chmod_script_if_valid "$file"
            done
            ;;
        2)
            echo -e "\n${GREEN}Prompting per directory...${NC}"
            find "$config_dir" -type d | while read -r dir; do
                scripts=$(find "$dir" -maxdepth 1 -type f -name "*.sh")
                [ -z "$scripts" ] && continue

                if ask_confirmation "Make scripts in $(realpath --relative-to="$DOTFILES_DIR" "$dir") executable?"; then
                    for file in $scripts; do
                        chmod_script_if_valid "$file"
                    done
                fi
            done
            ;;
        3)
            echo -e "\n${GREEN}Prompting per script...${NC}"
            find "$config_dir" -type f -name "*.sh" | while read -r file; do
                if ask_confirmation "Make $(realpath --relative-to="$DOTFILES_DIR" "$file") executable?"; then
                    chmod_script_if_valid "$file"
                fi
            done
            ;;
        *)
            echo -e "${YELLOW}Skipped config script permissions${NC}"
            ;;
    esac
}

# -------------------------------
# Home directory dotfiles
# -------------------------------

if ask_confirmation "Install home directory dotfiles?"; then
    echo -e "\n${GREEN}Installing home directory dotfiles...${NC}"
    for file in "$DOTFILES_DIR"/home/.*; do
        base="$(basename "$file")"
        if [ "$base" != "." ] && [ "$base" != ".." ]; then
            create_symlink "$file" "$HOME/$base"
        fi
    done
else
    echo -e "${YELLOW}Skipped home directory dotfiles${NC}"
fi

# -------------------------------
# .config directory
# -------------------------------

if [ -d "$DOTFILES_DIR/config" ]; then
    if ask_confirmation "Install .config directory files?"; then
        echo -e "\n${GREEN}Installing .config directory files...${NC}"
        for dir in "$DOTFILES_DIR"/config/*; do
            [ -d "$dir" ] || continue
            create_symlink "$dir" "$HOME/.config/$(basename "$dir")"
        done

        handle_config_scripts_permissions
    else
        echo -e "${YELLOW}Skipped .config directory files${NC}"
    fi
fi

# -------------------------------
# Scripts → ~/.local/bin
# -------------------------------

if [ -d "$DOTFILES_DIR/scripts" ]; then
    if ask_confirmation "Install scripts to ~/.local/bin?"; then
        echo -e "\n${GREEN}Installing scripts...${NC}"
        mkdir -p "$HOME/.local/bin"

        for script in "$DOTFILES_DIR"/scripts/*.sh; do
            [ -f "$script" ] || continue
            create_symlink "$script" "$HOME/.local/bin/$(basename "$script")"
            chmod_script_if_valid "$script"
        done
    else
        echo -e "${YELLOW}Skipped scripts installation${NC}"
    fi
fi

echo -e "\n${GREEN}Dotfiles installation complete!${NC}"
echo -e "${YELLOW}Note: You may need to restart your shell or reload Waybar/Hyprland${NC}"

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

# Home directory dotfiles
if ask_confirmation "Install home directory dotfiles?"; then
    echo -e "\n${GREEN}Installing home directory dotfiles...${NC}"
    for file in "$DOTFILES_DIR"/home/.*; do
        if [ "$(basename "$file")" != "." ] && [ "$(basename "$file")" != ".." ]; then
            create_symlink "$file" "$HOME/$(basename "$file")"
        fi
    done
else
    echo -e "${YELLOW}Skipped home directory dotfiles${NC}"
fi

# .config directory files
if [ -d "$DOTFILES_DIR/config" ]; then
    if ask_confirmation "Install .config directory files?"; then
        echo -e "\n${GREEN}Installing .config directory files...${NC}"
        for dir in "$DOTFILES_DIR"/config/*; do
            if [ -d "$dir" ]; then
                create_symlink "$dir" "$HOME/.config/$(basename "$dir")"
            fi
        done
    else
        echo -e "${YELLOW}Skipped .config directory files${NC}"
    fi
fi

# Scripts
if [ -d "$DOTFILES_DIR/scripts" ]; then
    if ask_confirmation "Install scripts to ~/.local/bin?"; then
        echo -e "\n${GREEN}Installing scripts...${NC}"
        mkdir -p "$HOME/.local/bin"
        for script in "$DOTFILES_DIR"/scripts/*.sh; do
            if [ -f "$script" ]; then
                create_symlink "$script" "$HOME/.local/bin/$(basename "$script")"
                chmod +x "$script"
            fi
        done
    else
        echo -e "${YELLOW}Skipped scripts installation${NC}"
    fi
fi

echo -e "\n${GREEN}Dotfiles installation complete!${NC}"
echo -e "${YELLOW}Note: You may need to restart your shell or source your config files${NC}"

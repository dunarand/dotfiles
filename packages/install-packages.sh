#!/bin/bash

set -e

ARCH_DISTROS=("arch" "manjaro" "cachyos")
DEBIAN_DISTROS=("debian" "ubuntu" "pop" "linuxmint")
FEDORA_DISTROS=("fedora")

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$SCRIPT_DIR/../packages"

detect_os() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]] || [[ -n "$WINDIR" ]]; then
        echo "windows"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

in_array() {
    local needle=$1
    shift
    local array=("$@")
    for item in "${array[@]}"; do
        if [[ "$item" == "$needle" ]]; then
            return 0
        fi
    done
    return 1
}

install_from_file() {
    local file=$1
    local installer=$2

    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}File $file not found, skipping...${NC}"
        return
    fi

    echo -e "${BLUE}Installing packages from $(basename "$file")...${NC}"

    packages=$(grep -v '^#' "$file" | grep -v '^$' | tr '\n' ' ')

    if [ -z "$packages" ]; then
        echo -e "${YELLOW}No packages found in $file${NC}"
        return
    fi

    echo -e "${GREEN}Packages to install: $packages${NC}"
    eval "$installer $packages"
}

OS=$(detect_os)
echo -e "${GREEN}Detected OS: $OS${NC}\n"

if in_array "$OS" "${ARCH_DISTROS[@]}"; then
    echo -e "${BLUE}=== Installing Arch Linux packages ===${NC}"

    echo -e "${YELLOW}Updating system...${NC}"
    sudo pacman -Syu --noconfirm

    if [ -f "$PACKAGES_DIR/$OS.txt" ]; then
        install_from_file "$PACKAGES_DIR/$OS.txt" "sudo pacman -S --needed --noconfirm"
    elif [ -f "$PACKAGES_DIR/arch.txt" ]; then
        install_from_file "$PACKAGES_DIR/arch.txt" "sudo pacman -S --needed --noconfirm"
    fi

    if command -v yay &> /dev/null; then
        if [ -f "$PACKAGES_DIR/aur.txt" ]; then
            echo -e "${BLUE}Installing AUR packages...${NC}"
            install_from_file "$PACKAGES_DIR/aur.txt" "yay -S --needed --noconfirm"
        fi
    elif command -v paru &> /dev/null; then
        if [ -f "$PACKAGES_DIR/aur.txt" ]; then
            echo -e "${BLUE}Installing AUR packages...${NC}"
            install_from_file "$PACKAGES_DIR/aur.txt" "paru -S --needed --noconfirm"
        fi
    else
        echo -e "${YELLOW}No AUR helper found (yay/paru). Skipping AUR packages.${NC}"
        echo -e "${YELLOW}Install yay with: git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si${NC}"
    fi

elif in_array "$OS" "${DEBIAN_DISTROS[@]}"; then
    echo -e "${BLUE}=== Installing Debian/Ubuntu packages ===${NC}"

    echo -e "${YELLOW}Updating package list...${NC}"
    sudo apt update

    if [ -f "$PACKAGES_DIR/$OS.txt" ]; then
        install_from_file "$PACKAGES_DIR/$OS.txt" "sudo apt install -y"
    elif [ -f "$PACKAGES_DIR/debian.txt" ]; then
        install_from_file "$PACKAGES_DIR/debian.txt" "sudo apt install -y"
    fi

    echo -e "${YELLOW}Upgrading system...${NC}"
    sudo apt upgrade -y

elif in_array "$OS" "${FEDORA_DISTROS[@]}"; then
    echo -e "${BLUE}=== Installing Fedora/RHEL packages ===${NC}"

    echo -e "${YELLOW}Updating system...${NC}"
    sudo dnf update -y

    if [ -f "$PACKAGES_DIR/$OS.txt" ]; then
        install_from_file "$PACKAGES_DIR/$OS.txt" "sudo dnf install -y"
    elif [ -f "$PACKAGES_DIR/fedora.txt" ]; then
        install_from_file "$PACKAGES_DIR/fedora.txt" "sudo dnf install -y"
    fi

elif [ "$OS" = "windows" ]; then
    echo -e "${BLUE}=== Windows detected ===${NC}"
    echo -e "${YELLOW}Please use install-packages.bat for Windows${NC}"
    exit 0

else
    echo -e "${RED}Unsupported OS: $OS${NC}"
    echo -e "${YELLOW}You can manually install packages from the appropriate file in $PACKAGES_DIR${NC}"
    exit 1
fi

if command -v flatpak &> /dev/null; then
    if [ -f "$PACKAGES_DIR/flatpak.txt" ]; then
        echo -e "\n${BLUE}=== Installing Flatpak packages ===${NC}"
        while IFS= read -r package; do
            [[ "$package" =~ ^#.*$ ]] && continue
            [[ -z "$package" ]] && continue

            echo -e "${GREEN}Installing flatpak: $package${NC}"
            flatpak install -y flathub "$package"
        done < "$PACKAGES_DIR/flatpak.txt"
    fi
else
    echo -e "\n${YELLOW}Flatpak not installed. Skipping flatpak packages.${NC}"
fi

if command -v npm &> /dev/null; then
    if [ -f "$PACKAGES_DIR/npm.txt" ]; then
        echo -e "\n${BLUE}=== Installing NPM global packages ===${NC}"
        install_from_file "$PACKAGES_DIR/npm.txt" "sudo npm install -g"
    fi
else
    echo -e "\n${YELLOW}NPM not installed. Skipping npm packages.${NC}"
fi

if command -v pip3 &> /dev/null || command -v pip &> /dev/null; then
    if [ -f "$PACKAGES_DIR/pip.txt" ]; then
        echo -e "\n${BLUE}=== Installing Python packages ===${NC}"
        PIP_CMD=$(command -v pip3 &> /dev/null && echo "pip3" || echo "pip")
        install_from_file "$PACKAGES_DIR/pip.txt" "$PIP_CMD install --user"
    fi
else
    echo -e "\n${YELLOW}Pip not installed. Skipping Python packages.${NC}"
fi

echo -e "\n${GREEN}✓ Package installation complete!${NC}"

#!/bin/bash

set -e

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

case "$OS" in
    windows)
        echo -e "${BLUE}=== Installing Windows packages with winget ===${NC}"
        
        if ! command -v winget &> /dev/null && ! command -v winget.exe &> /dev/null; then
            echo -e "${RED}winget is not installed or not in PATH${NC}"
            echo -e "${YELLOW}Please install winget from Microsoft Store or https://aka.ms/getwinget${NC}"
            exit 1
        fi
        
        WINGET_CMD=$(command -v winget &> /dev/null && echo "winget" || echo "winget.exe")
        
        echo -e "${YELLOW}Updating winget sources...${NC}"
        $WINGET_CMD source update
        
        if [ -f "$PACKAGES_DIR/windows.txt" ]; then
            echo -e "${BLUE}Installing packages from windows.txt...${NC}"
            while IFS= read -r package; do
                [[ "$package" =~ ^#.*$ ]] && continue
                [[ -z "$package" ]] && continue
                
                echo -e "${GREEN}Installing: $package${NC}"
                $WINGET_CMD install --id="$package" --exact --silent --accept-source-agreements --accept-package-agreements || echo -e "${YELLOW}Failed to install $package, continuing...${NC}"
            done < "$PACKAGES_DIR/windows.txt"
        fi
        ;;
        
    arch|manjaro)
        echo -e "${BLUE}=== Installing Arch Linux packages ===${NC}"
        
        echo -e "${YELLOW}Updating system...${NC}"
        sudo pacman -Syu --noconfirm
        
        if [ -f "$PACKAGES_DIR/arch.txt" ]; then
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
        ;;
        
    ubuntu|debian|pop|linuxmint)
        echo -e "${BLUE}=== Installing Debian/Ubuntu packages ===${NC}"
        
        echo -e "${YELLOW}Updating package list...${NC}"
        sudo apt update
        
        if [ -f "$PACKAGES_DIR/debian.txt" ]; then
            install_from_file "$PACKAGES_DIR/debian.txt" "sudo apt install -y"
        fi
        
        echo -e "${YELLOW}Upgrading system...${NC}"
        sudo apt upgrade -y
        ;;
        
    fedora|rhel|centos)
        echo -e "${BLUE}=== Installing Fedora/RHEL packages ===${NC}"
        
        echo -e "${YELLOW}Updating system...${NC}"
        sudo dnf update -y
        
        if [ -f "$PACKAGES_DIR/fedora.txt" ]; then
            install_from_file "$PACKAGES_DIR/fedora.txt" "sudo dnf install -y"
        fi
        ;;
        
    *)
        echo -e "${RED}Unsupported OS: $OS${NC}"
        echo -e "${YELLOW}You can manually install packages from the appropriate file in $PACKAGES_DIR${NC}"
        exit 1
        ;;
esac

if [ "$OS" != "windows" ]; then
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
fi

if command -v npm &> /dev/null; then
    if [ -f "$PACKAGES_DIR/npm.txt" ]; then
        echo -e "\n${BLUE}=== Installing NPM global packages ===${NC}"
        if [ "$OS" = "windows" ]; then
            install_from_file "$PACKAGES_DIR/npm.txt" "npm install -g"
        else
            install_from_file "$PACKAGES_DIR/npm.txt" "sudo npm install -g"
        fi
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

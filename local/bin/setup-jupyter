#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Setting up Jupyter for Molten ===${NC}\n"

echo -e "${YELLOW}Creating Jupyter runtime directory...${NC}"
mkdir -p ~/.local/share/jupyter/runtime
echo -e "${GREEN}✓ Runtime directory created${NC}\n"

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 not found. Please install Python first.${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking for ipykernel...${NC}"
if ! python3 -c "import ipykernel" 2> /dev/null; then
    echo -e "${YELLOW}ipykernel not found, installing...${NC}"
    pip3 install --user ipykernel
fi
echo -e "${GREEN}✓ ipykernel available${NC}\n"

echo -e "${YELLOW}Registering Python 3 kernel...${NC}"
python3 -m ipykernel install --user --name python3
echo -e "${GREEN}✓ Python 3 kernel registered${NC}\n"

echo -e "${YELLOW}Verifying kernel installation...${NC}"
if command -v jupyter &> /dev/null; then
    echo -e "\n${BLUE}Available kernels:${NC}"
    jupyter kernelspec list
else
    echo -e "${YELLOW}Jupyter not found in PATH. Kernel should still work with Molten.${NC}"
fi

echo -e "\n${GREEN}✓ Jupyter setup complete!${NC}"
echo -e "${BLUE}You can now use Molten in Neovim with <leader>mi${NC}"

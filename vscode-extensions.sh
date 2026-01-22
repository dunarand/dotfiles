#!/bin/bash

if [ -f "$HOME/dotfiles/config/Code/User/extensions.txt" ]; then
    cat "$HOME/dotfiles/config/Code/User/extensions.txt" | xargs -L 1 code --install-extension
    echo "VS Code extensions installed"
else
    echo "extensions.txt not found"
fi

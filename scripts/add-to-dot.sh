#!/usr/bin/env bash

DOTFILES_DIR="$HOME/dotfiles"

# Determine repo-relative target based on source path
get_repo_path() {
    local src="$(realpath "${1%/}")"

    if [[ "$src" == "$HOME/.config/"* ]]; then
        echo "$DOTFILES_DIR/config/${src#$HOME/.config/}"
    elif [[ "$src" == "$HOME/.local/bin/"* ]]; then
        echo "$DOTFILES_DIR/scripts/${src#$HOME/.local/bin/}"
    elif [[ "$src" == "$HOME/"* || "$src" == "$HOME" ]]; then
        echo "$DOTFILES_DIR/home/${src#$HOME/}"
    else
        echo "ERROR: Don't know where to put $src in the repo" >&2
        return 1
    fi
}

if [[ $# -eq 0 ]]; then
    echo "Usage: $(basename "$0") <file|dir> [...]"
    exit 1
fi

for target in "$@"; do
    # Resolve absolute path, handling trailing slashes
    target="${target%/}"
    abs="$(realpath "$target" 2>/dev/null)"

    if [[ ! -e "$abs" ]]; then
        echo "Error: '$target' does not exist, skipping."
        continue
    fi

    if [[ -L "$abs" ]]; then
        echo "Warning: '$target' is already a symlink, skipping."
        continue
    fi

    repo_path="$(get_repo_path "$abs")" || continue

    if [[ -e "$repo_path" ]]; then
        echo "Error: '$repo_path' already exists in the repo, skipping."
        continue
    fi

    # Create parent dirs in repo if needed
    mkdir -p "$(dirname "$repo_path")"

    # Move to repo
    mv "$abs" "$repo_path"
    echo "Moved:    $abs → $repo_path"

    # Symlink back to original location
    ln -s "$repo_path" "$abs"
    echo "Linked:   $abs → $repo_path"
    echo
done

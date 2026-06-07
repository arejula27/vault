#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/arejula27/dotfiles"
DOTFILES_DIR="${HOME}/dotfiles"
FLAG="${HOME}/.config/vault/.dotfiles-applied"

if [[ -f "$FLAG" ]]; then
    exit 0
fi

if [[ ! -d "$DOTFILES_DIR" ]]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
stow . --target="$HOME" --no-folding

mkdir -p "$(dirname "$FLAG")"
touch "$FLAG"

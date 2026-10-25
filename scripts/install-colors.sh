#!/usr/bin/env bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

apps=(
  "bat"
  "btop"
#    "firefox"
#    "fzf"
#    "gtk"
#    "nvim"
#    "tmux"
#    "vscode"
)

for app in "${apps[@]}"; do
  git clone "https://github.com/catppuccin/${app}.git" "tmp/${app}"
done

# Bat
mkdir -p "$(bat --config-dir)/themes"
cp tmp/bat/themes/*.tmTheme "$(bat --config-dir)/themes/"
bat cache --build

# btop
mv tmp/btop/themes/* "${HOME}/.config/btop/themes/"

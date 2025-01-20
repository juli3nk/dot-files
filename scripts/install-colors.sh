#!/usr/bin/env bash

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

apps=(
  "bat"
  "btop"
#    "dmenu"
#    "firefox"
#    "fzf"
#    "gtk"
#    "hyprland"
#    "kitty"
#    "mako"
#    "nvim"
#    "tmux"
#    "vscode"
)

if [ "$(is_gui)" -eq 1 ]; then
  apps+=("alacritty")
fi

for app in "${apps[@]}"; do
  git clone "https://github.com/catppuccin/${app}.git" "tmp/${app}"
done

# Bat
mkdir -p "$(bat --config-dir)/themes"
cp tmp/bat/themes/*.tmTheme "$(bat --config-dir)/themes/"
bat cache --build

# btop
mv tmp/btop/themes/* "${HOME}/.config/btop/themes/"

# Configure GUI related apps
if [ "$(is_gui)" -eq 0 ]; then
  exit
fi

# Alacritty
mv tmp/alacritty "${HOME}/.config/alacritty/catppuccin"

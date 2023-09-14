#!/usr/bin/env bash

apps=(
  "alacritty"
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

for app in "${apps[@]}"; do
  git clone "https://github.com/catppuccin/${app}.git" "tmp/${app}"
done

# Alacritty
mv tmp/alacritty ~/.config/alacritty/catppuccin

# Bat
mkdir -p "$(bat --config-dir)/themes"
cp tmp/bat/*.tmTheme "$(bat --config-dir)/themes/"
bat cache --build

# btop
mv tmp/btop/themes/* ~/.config/btop/themes/

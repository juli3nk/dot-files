#!/usr/bin/env bash

declare -a extensions=(
  "aaron-bond.better-comments"
  "Catppuccin.catppuccin-vsc"
  "DavidAnson.vscode-markdownlint"
  "donjayamanne.githistory"
  "editorconfig.editorconfig"
  "formulahendry.auto-close-tag"
  "jeremyljackson.vs-docblock"
  "ms-azuretools.vscode-docker"
  "ms-python.python"
  "ms-vscode-remote.remote-containers"
  "ms-vscode-remote.remote-wsl"
  "oderwat.indent-rainbow"
  "vscode-icons-team.vscode-icons"
  "chouzz.vscode-better-align"
  "yzhang.markdown-all-in-one"
)


for extension in "${extensions[@]}"; do
  echo -e "https://marketplace.visualstudio.com/items?itemName=${extension}"

  code --install-extension "$extension"
done

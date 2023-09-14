#!/usr/bin/env bash

declare -a extensions=(
  "4ops.terraform"
  "aaron-bond.better-comments"
  "bbenoist.nix"
  "Catppuccin.catppuccin-vsc"
  "DavidAnson.vscode-markdownlint"
  "dbaeumer.vscode-eslint"
  "donjayamanne.githistory"
  "editorconfig.editorconfig"
  "formulahendry.auto-close-tag"
  "golang.go"
  "jeremyljackson.vs-docblock"
  "ms-azuretools.vscode-docker"
  "ms-python.python"
  "ms-vscode.go"
  "ms-vscode-remote.remote-containers"
  "oderwat.indent-rainbow"
  "vscode-icons-team.vscode-icons"
  "wwm.better-align"
  "yzhang.markdown-all-in-one"
)


for extension in "${extensions[@]}"; do
  echo -e "https://marketplace.visualstudio.com/items?itemName=${extension}"

  code --install-extension "$extension"
done

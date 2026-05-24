#!/usr/bin/env bash
set -e

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

LOCAL_BIN="${HOME}/.local/bin"
PATH=${LOCAL_BIN}:${PATH}

# asdf
ASDF_DIR_PATH="${HOME}/.asdf"
ASDF_REPO_URL="github.com/asdf-vm/asdf"

ASDF_VERSION="$(get_latest_tag "$ASDF_REPO_URL")"

mkdir -p "$LOCAL_BIN"

if [ ! -f "${LOCAL_BIN}/bin/asdf" ]; then
  curl -sfL "https://${ASDF_REPO_URL}/releases/download/v${ASDF_VERSION}/asdf-v${ASDF_VERSION}-linux-amd64.tar.gz" | tar -xzC "$LOCAL_BIN"
fi

# Install apps using asdf
declare -a apps=(
  "age"
  "bat;https://github.com/juli3nk/asdf-bat.git"
  "bottom"
  "dotfiles;https://github.com/juli3nk/asdf-dotfiles.git"
  "eza;https://github.com/juli3nk/asdf-eza.git"
  "github-cli"
  "lefthook"
  "neovim;https://github.com/juli3nk/asdf-neovim.git"
  "pluto"
  "ripgrep"
  "sops"
  "yq"
  "zoxide"
)

for app in "${apps[@]}"; do
  app_name="$(echo "$app" | awk -F';' '{ print $1 }')"
  app_url="$(echo "$app" | awk -F';' '{ print $2 }')"

  asdf plugin add "$app_name" "$app_url"
  asdf install "$app_name" latest
done

# FZF
if [ ! -d "${HOME}/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
  "${HOME}/.fzf/install"
fi

# Install GUI related apps
if [ "$(is_gui)" -eq 0 ]; then
  exit
fi

# mybar
mybar_repo_url="github.com/juli3nk/mybar-barista"

mybar_version_latest="$(get_latest_tag "$mybar_repo_url")"

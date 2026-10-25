#!/usr/bin/env bash
set -e

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

LOCAL_BIN="${HOME}/.local/bin"
PATH="${LOCAL_BIN}:${PATH}"

mkdir -p "$LOCAL_BIN"

# Mise
if [ ! -f "${LOCAL_BIN}/bin/mise" ]; then
  curl https://mise.run | sh
fi

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

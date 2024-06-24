#!/usr/bin/env bash
set -e

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

# asdf
ASDF_DIR_PATH="${HOME}/.asdf"
ASDF_REPO_URL="github.com/asdf-vm/asdf"

ASDF_VERSION="$(get_latest_tag "$ASDF_REPO_URL")"

if [ ! -d "$ASDF_DIR_PATH" ]; then
  git clone "https://${ASDF_REPO_URL}.git" "$ASDF_DIR_PATH" --branch "v${ASDF_VERSION}"
fi

. "${ASDF_DIR_PATH}/asdf.sh"

# Install apps using asdf
declare -a apps=(
  "age"
  "bat;https://github.com/juli3nk/asdf-bat.git"
  "cosign"
  "ctop"
  "dagger"
  "dotfiles;https://github.com/juli3nk/asdf-dotfiles.git"
  "eza;https://github.com/juli3nk/asdf-eza.git"
  "github-cli"
  "helm"
  "kind"
  "krew"
  "kubectl"
  "kubent"
  "neovim;https://github.com/juli3nk/asdf-neovim.git"
  "nerdctl"
  "pluto"
  "ripgrep"
  "sops"
  "step"
  "yq"
  "zoxide"
)

for app in "${apps[@]}"; do
  app_name="$(echo "$app" | awk -F';' '{ print $1 }')"
  app_url="$(echo "$app" | awk -F';' '{ print $2 }')"

  asdf plugin add "$app_name" "$app_url"
  asdf install "$app_name" latest
  asdf global "$app_name" latest
done

# FZF
if [ ! -d "${HOME}/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "${HOME}/.fzf"
  "${HOME}/.fzf/install"
fi

# Skopeo
#git clone http://github.com/containers/skopeo.git /tmp/skopeo
#pushd /tmp/skopeo
#make binary
#popd

# Kubectl plugins
declare -a kubectl_plugins=(
  "neat"
  "stern"
  "outdated"
  "view-cert"
  "view-secret"
)

for plugin in "${kubectl_plugins[@]}"; do
  kubectl krew install "$plugin"
done

# Helm plugins
declare -a helm_plugins=(
  "https://github.com/databus23/helm-diff"
  "https://github.com/jkroepke/helm-secrets"
)

for plugin in "${helm_plugins[@]}"; do
  helm plugin install "$plugin"
done


# Install GUI related apps
if [ "$(is_gui)" -eq 0 ]; then
  exit
fi

# mybar
mybar_repo_url="github.com/juli3nk/mybar-barista"

mybar_version_latest="$(get_latest_tag "$mybar_repo_url")"

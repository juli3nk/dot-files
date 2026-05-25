#!/usr/bin/env bash
set -e

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

PATH=${HOME}/.local/bin:${PATH}

# Install apps using asdf
declare -a apps=(
  "cosign"
  "ctop"
  "dagger"
  "nerdctl"
)

  "github-cli"

for app in "${apps[@]}"; do
  app_name="$(echo "$app" | awk -F';' '{ print $1 }')"
  app_url="$(echo "$app" | awk -F';' '{ print $2 }')"

  asdf plugin add "$app_name" "$app_url"
  asdf install "$app_name" latest
done

# Skopeo
#git clone http://github.com/containers/skopeo.git /tmp/skopeo
#pushd /tmp/skopeo
#make binary
#popd

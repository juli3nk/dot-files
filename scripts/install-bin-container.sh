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

for app in "${apps[@]}"; do
  mise use -g "$app"
done

# Skopeo
#git clone http://github.com/containers/skopeo.git /tmp/skopeo
#pushd /tmp/skopeo
#make binary
#popd

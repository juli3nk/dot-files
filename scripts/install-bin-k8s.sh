#!/usr/bin/env bash
set -e

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

PATH=${HOME}/.local/bin:${PATH}


# Install apps using asdf
declare -a apps=(
  "helm"
  "kind"
  "krew"
  "kubectl"
  "kubent"
)

for app in "${apps[@]}"; do
  app_name="$(echo "$app" | awk -F';' '{ print $1 }')"
  app_url="$(echo "$app" | awk -F';' '{ print $2 }')"

  asdf plugin add "$app_name" "$app_url"
  asdf install "$app_name" latest
done

# Kubectl plugins
# https://krew.sigs.k8s.io/plugins/
declare -a kubectl_plugins=(
  "config-doctor"
  "ctx"
  "neat"
  "ns"
  "outdated"
  "stern"
  "view-cert"
  "view-secret"
  "view-utilization"
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

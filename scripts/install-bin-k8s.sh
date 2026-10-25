#!/usr/bin/env bash
set -e

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

PATH=${HOME}/.local/bin:${PATH}


# Install apps using mise
declare -a apps=(
  "helm"
  "kind"
  "krew"
  "kubectl"
  "kubent"
)

for app in "${apps[@]}"; do
  mise use -g "$app"
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

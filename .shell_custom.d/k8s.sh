
alias k='kubectl'

kc_cert_info() {
  kubectl get secret "$1" -o jsonpath="{.data.tls\.crt}" | base64 -d | openssl x509 -noout -text
}
alias kc-cert-info='kc_cert_info'

update-kubeconfig() {
  kubeconfigs=""
  profile=${1:-*}

  kube_config="${HOME}/.kube/config"

  for kc in $(find ${HOME}/.kube/contexts/ -maxdepth 1 -name "${profile}.y*ml"); do
    kubeconfigs+="${kc}:"
  done

  KUBECONFIG="$(echo $kubeconfigs | sed 's/:$//')" kubectl config view --merge --flatten > "$kube_config"
  chmod 600 "$kube_config"
}

kcctx() {
  if [ "$1" == "ls" ]; then
    kubectl config get-contexts | sort
  fi

  if [ "$1" == "use" ]; then
    context_name="$2"

    if [ -z "$2" ]; then
      context_name=$(kubectl config get-contexts -o name | sort | fzf)
    fi

    kubectl config use-context "$context_name"
  fi
}

kcns() {
  if [ "$1" == "ls" ]; then
    kubectl get ns
  fi

  if [ "$1" == "use" ]; then
    ns_name="$2"

    if [ -z "$2" ]; then
      ns_name=$(kubectl get ns -o name | sed 's#namespace/##' | sort | fzf)
    fi

    kubectl config set-context --current --namespace "$ns_name"
  fi
}

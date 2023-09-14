
alias k='kubectl'

alias kcgn='kubectl get node -o wide'
alias kcgd='kubectl get deployment -o wide'
alias kcgp='kubectl get pod -o wide'
alias kcgs='kubectl get service -o wide'
alias kcgi='kubectl get ingress -o wide'
alias kcdd='kubectl describe deployment'
alias kcdp='kubectl describe pod'
alias kcds='kubectl describe service'
alias kcdi='kubectl describe ingress'

kc_cert_info() {
  kubectl get secret $1 -o jsonpath="{.data.tls\.crt}" | base64 -d | openssl x509 -noout -text
}
alias kc-cert-info='kc_cert_info'

kclf() {
  local tail=${2:100}

  kubectl logs --tail="$tail" -f "$1"
}

kcsh() {
  local shell="${2:-bash}"

  kubectl exec -ti "$1" -- "$shell"
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

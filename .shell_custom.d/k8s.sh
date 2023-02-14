
alias kcgs='kubectl get service -o wide'
alias kcgd='kubectl get deployment -o wide'
alias kcgp='kubectl get pod -o wide'
alias kcgn='kubectl get node -o wide'
alias kcgi='kubectl get ingress -o wide'
alias kcdp='kubectl describe pod'
alias kcds='kubectl describe service'
alias kcdd='kubectl describe deployment'
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
	local shell=${2:-bash}

	kubectl exec -ti "$1" -- $shell
}

update_kubeconfig() {
	local kubeconfigs
	local profile=${1:-*}

	local kube_config="${HOME}/.kube/config"

	for kc in $(find ${HOME}/.kubeconfig.d/ -maxdepth 1 -name "${profile}.y*ml"); do
		kubeconfigs+="${kc}:"
	done

	KUBECONFIG=$(echo $kubeconfigs | sed 's/:$//') kubectl config view --merge --flatten > "$kube_config"
	chmod 600 "$kube_config"
}
alias update-kubeconfig='update_kubeconfig'

kcctx() {
	if [ "$1" == "ls" ]; then
		kubectl config get-contexts
	fi

	if [ "$1" == "use" ]; then
		kubectl config use-context "$2"
	fi

	if [ "$1" == "switch" ]; then
		#local contexts=$(kubectl config get-contexts -o name)
		kubectl config get-contexts -o name

		read -p "Your choice: " -r
		echo

		if [ -z "$REPLY" ]; then
			return 1
		fi

		kubectl config use-context "$REPLY"
	fi
}

kcns() {
	if [ "$1" == "ls" ]; then
		kubectl get ns
	fi

	if [ "$1" == "use" ]; then
		kubectl config set-context --current --namespace "$2"
	fi
}

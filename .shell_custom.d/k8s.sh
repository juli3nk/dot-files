
alias kclf='kubectl logs --tail=200 -f'
alias kcgs='kubectl get service -o wide'
alias kcgd='kubectl get deployment -o wide'
alias kcgp='kubectl get pod -o wide'
alias kcgn='kubectl get node -o wide'
alias kcgi='kubectl get ingress -o wide'
alias kcdp='kubectl describe pod'
alias kcds='kubectl describe service'
alias kcdd='kubectl describe deployment'
alias kcdi='kubectl describe ingress'

alias kbctx='kubectl config use-context'
alias kbns='kubectl config set-context --current --namespace'

gcm() { kubectl get configmap $@ -o yaml; }
kclfl() { kubectl logs --tail=$@  -f; }
kcpf() {
	result=$(kubectl get pod | grep -m1 $@)
        exitCode=$?
        if [ ! "$exitCode" -eq 0 ]; then
	 	echo "Could not find pod matching [$@]."
	 	return 1;
	fi
        podName=$(echo $result | awk '{print $1}')
	echo "Forwarding port 8080 of $podName to local port 8080"
	kubectl port-forward $podName 8080:8080
}
kcxsh() { kubectl exec -ti $@ sh; }
kcxbash() { kubectl exec -ti $@ bash; }

#kccl() {
#}

update-kubeconfig() {
	local kubeconfigs=""
	local profile=${1:-*}

	for kc in ${HOME}/.kubeconfig.d/${profile}.yml; do
		kubeconfigs+="${kc}:"
	done

	KUBECONFIG=$(echo $kubeconfigs | sed 's/:$//') kubectl config view --merge --flatten > $HOME/.kube/config
}

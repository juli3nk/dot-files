if [ -f "${SSH_AGENT_ENABLED}" ]; then
	ssh-add -D
	ssh-agent -k
fi

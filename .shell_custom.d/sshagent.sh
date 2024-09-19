SSH_ENV_FILE="${HOME}/.ssh/environment"

start_agent() {
  if [ -f "$SSH_ENV_FILE" ]; then
    SSH_AGENT_PID_ENV_FILE="$(awk -F';' '/SSH_AGENT_PID=/ { print $1 }' "$SSH_ENV_FILE" | awk -F'=' '{ print $2 }')"
    SSH_AGENT_PID_SHELL="$(ps ux | awk '/[s]sh-agent/ { print $2 }')"

    if [ "$SSH_AGENT_PID_ENV_FILE" == "$SSH_AGENT_PID_SHELL" ]; then
      source "$SSH_ENV_FILE" > /dev/null

      return
    else
      for pid in ${SSH_AGENT_PID_SHELL}; do
        SSH_AGENT_PID="$pid" ssh-agent -k
      done
    fi
  fi

  if [ "$(ps ux | grep -c "[s]sh-agent")" -eq 0 ]; then
    echo "Initialising SSH agent ..."
    ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV_FILE"
    echo -e "succeeded"

    chmod 600 "$SSH_ENV_FILE"
    source "$SSH_ENV_FILE" > /dev/null
  fi
}

add_identity() {
  if [ "$(ssh-add -l | grep -vc "The agent has no identities.")" -eq 0 ]; then
    ssh-add
  fi
}


start_agent
add_identity

unset -f start_agent
unset -f add_identity

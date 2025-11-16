SSH_ENV_FILE="${HOME}/.ssh/environment"

start_ssh_agent() {
  if [ -f "$SSH_ENV_FILE" ]; then
    SSH_AGENT_PID_ENV_FILE="$(awk -F';' '/SSH_AGENT_PID=/ { print $1 }' "$SSH_ENV_FILE" | awk -F'=' '{ print $2 }')"
    SSH_AGENT_PID_SHELL="$(pgrep -u "$USER" -x ssh-agent)"

    if [ "$SSH_AGENT_PID_ENV_FILE" == "$SSH_AGENT_PID_SHELL" ]; then
      source "$SSH_ENV_FILE" > /dev/null

      return 0
    else
      rm -f "$SSH_ENV_FILE"
      pkill -u "$USER" -x ssh-agent || true
    fi
  fi

  if ! pgrep -u "$USER" -x ssh-agent >/dev/null 2>&1; then
    echo "Initialising SSH agent ..."

    ssh-agent | sed 's/^echo/#echo/' > "$SSH_ENV_FILE"
    chmod 600 "$SSH_ENV_FILE"

    echo -e "succeeded"
  fi
}

use_gpg_agent() {
  local sock
  sock="$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null || true)"

  if [[ -n "$sock" && -S "$sock" ]]; then
    echo SSH_AUTH_SOCK="$sock" > "$SSH_ENV_FILE"
    echo "SSH_AGENT_PID=" >> "$SSH_ENV_FILE"

    return 0
  fi

  return 1
}

add_identity() {
  if ! ssh-add -l >/dev/null 2>&1; then
    echo "Loading default SSH key..."
    ssh-add
  fi
}


if ! use_gpg_agent; then
  start_ssh_agent
fi

source "$SSH_ENV_FILE" > /dev/null

add_identity

unset -f \
  add_identity \
  start_ssh_agent \
  use_gpg_agent

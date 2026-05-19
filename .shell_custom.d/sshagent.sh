SSH_ENV_FILE="${HOME}/.ssh/environment"

use_gpg_agent() {
  local sock
  sock="$(gpgconf --list-dirs agent-ssh-socket 2>/dev/null)"

  # Vérifier que gpg-agent est réellement actif
  if [[ -n "$sock" ]] && [[ -S "$sock" ]] && gpgconf --list-components | grep -q 'gpg-agent:'; then
    # export SSH_AUTH_SOCK="$sock"
    # unset SSH_AGENT_PID

    # Optionnel : sauvegarder dans le fichier pour cohérence
    printf 'SSH_AUTH_SOCK=%s\n' "$sock" > "$SSH_ENV_FILE"
    printf 'SSH_AGENT_PID=\n' >> "$SSH_ENV_FILE"
    chmod 600 "$SSH_ENV_FILE"

    return 0
  fi

  return 1
}

start_ssh_agent() {
  # Nettoyer les anciens agents zombies
  if [[ -f "$SSH_ENV_FILE" ]]; then
    SSH_AGENT_PID_ENV_FILE="$(awk -F';' '/SSH_AGENT_PID=/ { print $1 }' "$SSH_ENV_FILE" | awk -F'=' '{ print $2 }')"
    SSH_AGENT_PID_SHELL="$(pgrep -u "$USER" -x ssh-agent)"

    if [ "$SSH_AGENT_PID_ENV_FILE" == "$SSH_AGENT_PID_SHELL" ]; then
      # Agent valide, on le garde
      return 0
    fi

    # Nettoyer
    rm -f "$SSH_ENV_FILE"
    pkill -u "$USER" ssh-agent 2>/dev/null || true
  fi

  # Démarrer un nouvel agent
  echo "Initialising SSH agent ..."
  ssh-agent -s | grep -v '^echo' > "$SSH_ENV_FILE"
  chmod 600 "$SSH_ENV_FILE"
}

load_ssh_keys() {
  if ! ssh-add -l &>/dev/null; then
    case $? in
      0) return 0 ;;  # Clés chargées
      1)
        echo "Loading default SSH key..."
        ssh-add
      ;;   # Agent actif mais pas de clés
      2) return 1 ;;  # Pas d'agent (ne devrait pas arriver)
    esac
  fi
}


if ! use_gpg_agent; then
  start_ssh_agent
fi

source "$SSH_ENV_FILE" > /dev/null

load_ssh_keys

unset -f \
  use_gpg_agent \
  start_ssh_agent \
  load_ssh_keys


# Detect the desktop environment (i3 or sway)
get_desktop_environment() {
  local de
  de=$(printf "%s%s" "${XDG_SESSION_DESKTOP:-}" "${XDG_CURRENT_DESKTOP:-}" \
    | grep -oE 'i3|sway' | head -n 1)
  echo "$de"
}

# Ensure the desktop environment is supported
is_desktop_environment_supported() {
  local de="$1"
  if [[ "$de" != "i3" && "$de" != "sway" ]]; then
    echo "Unsupported desktop environment: ${de}" >&2
    exit 1
  fi
}

# Send a message to the window manager (with optional debug)
wmmsg() {
  local de
  if [[ "$1" == "i3" || "$1" == "sway" ]]; then
    de="$1"
    shift
  else
    is_desktop_environment_supported "unknown"
  fi

  if [[ "${DEBUG:-0}" -eq 1 ]] && declare -F log >/dev/null; then
    log debug "Sending message to window manager (${de}): $*"
  fi

  case "$de" in
    i3)   i3-msg "$@" ;;
    sway) swaymsg "$@" ;;
  esac
}

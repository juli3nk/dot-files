#!/usr/bin/env bash

get_desktop_environment() {
  echo "${XDG_SESSION_DESKTOP:-}${XDG_CURRENT_DESKTOP:-}" | grep -oE 'i3|sway' | head -n 1
}

wmmsg() {
  case "$DE" in
    i3)
      i3-msg "$@"
      ;;
    sway)
      swaymsg "$@"
      ;;
  esac
}

DE="$(get_desktop_environment)"

wmmsg exit

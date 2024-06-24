#!/usr/bin/env bash

wmmsg() {
  if [ "$XDG_SESSION_DESKTOP" == "sway" ] || [ "$XDG_CURRENT_DESKTOP" == "sway" ]; then
    swaymsg "$@"
  fi
  if [ "$XDG_SESSION_DESKTOP" == "i3" ] || [ "$XDG_CURRENT_DESKTOP" == "i3" ]; then
    i3-msg "$@"
  fi
}

wmmsg exit

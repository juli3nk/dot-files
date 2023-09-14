#!/usr/bin/env bash

STATE_FILE="/tmp/audio-profile.state"

cd "${HOME}/.wm"

case "$1" in
  call)
    if [ $(./playerctl.sh status | grep -c "playing") -eq 1 ]; then
      ./playerctl.sh play-pause
      ./audio-vol.sh set 50
      ./audio-vol.sh micunmute
    else
      ./audio-vol.sh micmute
      ./audio-vol.sh set 31
      ./playerctl.sh play-pause
    fi
esac

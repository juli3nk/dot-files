#!/usr/bin/env bash

MUSIC_STATE="/tmp/music-state"

create-music-state() {
  touch "$MUSIC_STATE"
}

remove-music-state() {
  rm -f "$MUSIC_STATE"
}

music-pause() {
  if [ "$("${HOME}/.wm/playerctl.sh" status | grep -ic "playing")" -eq 1 ]; then
    create-music-state
    "${HOME}/.wm/playerctl.sh" play-pause
  fi
}

music-play() {
  if [ -f "$MUSIC_STATE" ]; then
    remove-music-state
    "${HOME}/.wm/playerctl.sh" play-pause
  fi
}

audio-set-mute() {
  wpctl set-mute @DEFAULT_AUDIO_SINK@ "$1"
  wpctl set-mute @DEFAULT_AUDIO_SOURCE@ "$1"
}

fingerprint-verify() {
  (while pidof "$1"; do
    if (fprintd-verify | grep verify-match); then
      killall "$1"
    fi
  done) &
}

wmlock() {
  if [ "$XDG_SESSION_DESKTOP" == "sway" ] || [ "$XDG_CURRENT_DESKTOP" == "sway" ]; then
    swaylock -f -c 000000
    fingerprint-verify "swaylock"
  fi
  if [ "$XDG_SESSION_DESKTOP" == "i3" ] || [ "$XDG_CURRENT_DESKTOP" == "i3" ]; then
    i3lock --nofork --ignore-empty-password --color=000000 &
    fingerprint-verify "i3lock"
  fi
}

wmmsg() {
  if [ "$XDG_SESSION_DESKTOP" == "sway" ] || [ "$XDG_CURRENT_DESKTOP" == "sway" ]; then
    swaymsg "$@"
  fi
  if [ "$XDG_SESSION_DESKTOP" == "i3" ] || [ "$XDG_CURRENT_DESKTOP" == "i3" ]; then
    i3-msg "$@"
  fi
}

same-wifi() {
  if [ "$1" != "idle" ]; then
    return
  fi

  wifi_home="$(jq -r '.wifi.home' "${HOME}/.config/local/net.json")"
  wifi_current="$(nmcli c show --active | awk '/wifi/ { print $1 }')"

  if [ "$wifi_home" != "none" ] && [ "$wifi_current" == "$wifi_home" ]; then
    exit
  fi
}


lock_type="${2:-regular}"

case "$1" in
  lock)
    same-wifi "$lock_type"

    remove-music-state
    music-pause
    audio-set-mute "1"

    wmlock
    ;;
  lock-soft)
    same-wifi "$lock_type"

    wmlock
    ;;
  off)
    wmmsg "output * dpms off"
    ;;
  resume)
    wmmsg "output * dpms on"
    audio-set-mute "0"
    ;;
esac

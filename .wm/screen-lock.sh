#!/usr/bin/env bash
# This script locks the screen, pauses the music, and mutes the audio based on the system's state.
# Options:
#   lock - locks the screen and pauses the music
#   lock-soft - locks the screen without touching the music
#   off - turns off the screen
#   resume - wakes up the screen and restores the audio settings
#
# Variables:
#   DEBUG=1 to enable debug mode (displays actions without executing them)

set -e

. "${HOME}/.local/lib/de.sh"
. "${HOME}/.local/lib/log.sh"
. "${HOME}/.local/lib/utils.sh"

MUSIC_STATE="/tmp/music-state"
DEBUG="${DEBUG:-0}"

create_music_state() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Creating music state file at ${MUSIC_STATE}"
  else
    touch "$MUSIC_STATE"
    chmod 600 "$MUSIC_STATE"
  fi
}

remove_music_state() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Removing music state file at ${MUSIC_STATE}"
  else
    rm -f "$MUSIC_STATE"
  fi
}

music_pause() {
  if [ "$("${HOME}/.wm/playerctl.sh" status | grep -ic "playing")" -eq 1 ]; then
    create_music_state
    if [ "$DEBUG" -eq 1 ]; then
      log debug "Pausing music"
    else
      "${HOME}/.wm/playerctl.sh" play-pause
    fi
  fi
}

music_play() {
  if [ -f "$MUSIC_STATE" ]; then
    remove_music_state
    if [ "$DEBUG" -eq 1 ]; then
      log debug "Resuming music"
    else
      "${HOME}/.wm/playerctl.sh" play-pause
    fi
  fi
}

audio_set_mute() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Muting audio (microphone and speakers)"
  else
    ${HOME}/.wm/audio-vol.sh mute
    ${HOME}/.wm/audio-vol.sh micmute
  fi
}

fingerprint_verify() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Verifying fingerprint for $1"
  else
    (while pidof "$1"; do
      if (fprintd-verify | grep verify-match); then
        killall "$1"
      fi
    done) &
  fi
}

lock_screen() {
  case "$DE" in
    i3)
      i3lock --nofork --ignore-empty-password --color=000000 &
      fingerprint_verify "i3lock"
      ;;
    sway)
      swaylock -f -c 000000
      fingerprint_verify "swaylock"
      ;;
  esac
}

wmlock() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Locking screen with wmlock"
  else
    lock_screen
  fi
}

same_wifi() {
  if [ "$1" != "idle" ]; then
    return
  fi

  wifi_home="$(jq -r '.wifi.home' "${HOME}/.config/local/net.json")"
  wifi_current="$(nmcli c show --active | awk '/wifi/ { print $1 }')"

  if [ "$wifi_home" != "none" ] && [ "$wifi_current" == "$wifi_home" ]; then
    log info "Already connected to the home Wi-Fi."
    exit
  fi
}

check_temp_file() {
  if [ "$1" == "idle" ] && [ -f "/tmp/screen-lock-temp" ]; then
    log info "Temporary lock file present."
    exit
  fi
}


DE="$(get_desktop_environment)"
is_desktop_environment_supported "$DE"

for cmd in jq nmcli playerctl wpctl; do
  command_exists "$cmd"
done

lock_type="${2:-regular}"

case "$1" in
  lock)
    check_temp_file "$lock_type"
    same_wifi "$lock_type"

    remove_music_state
    music_pause
    audio_set_mute

    wmlock
    ;;
  lock-soft)
    check_temp_file "$lock_type"
    same_wifi "$lock_type"

    wmlock
    ;;
  off)
    check_temp_file "$lock_type"
    same_wifi "$lock_type"

    wmmsg "output * dpms off"
    ;;
  resume)
    wmmsg "output * dpms on"

    if [ -f "$MUSIC_STATE" ]; then audio_set_mute "0" ; fi
    ;;
  *)
    log error "Invalid option. Usage: lock | lock-soft | off | resume"
    ;;
esac

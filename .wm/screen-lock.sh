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

MUSIC_STATE="/tmp/music-state"
DEBUG="${DEBUG:-0}"

# ANSI color codes
reset="\e[0m"
red="\e[1;31m"
blue="\e[1;34m"
orange="\e[38;5;214m"
green="\e[1;32m"
purple="\e[1;35m"
yellow="\e[1;33m"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

log() {
  local level
  local msg="$2"

  case "$1" in
    fatal) level="${red}FATAL${reset}" ;;
    error) level="${red}ERROR${reset}" ;;
    warning) level="${orange}WARNING${reset}" ;;
    success) level="${green}SUCCESS${reset}" ;;
    debug) level="${purple}DEBUG${reset}" ;;
    info|*) level="${blue}INFO${reset}" ;;  # Default is INFO
  esac

  echo -e "${level}: ${msg}"
}

get_desktop_environment() {
  echo "$XDG_SESSION_DESKTOP" "$XDG_CURRENT_DESKTOP" | grep -oE 'sway|i3' | head -n 1
}

create-music-state() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Creating music state file at $MUSIC_STATE"
  else
    touch "$MUSIC_STATE"
    chmod 600 "$MUSIC_STATE"
  fi
}

remove-music-state() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Removing music state file at $MUSIC_STATE"
  else
    rm -f "$MUSIC_STATE"
  fi
}

music-pause() {
  if [ "$("${HOME}/.wm/playerctl.sh" status | grep -ic "playing")" -eq 1 ]; then
    create-music-state
    if [ "$DEBUG" -eq 1 ]; then
      log debug "Pausing music"
    else
      "${HOME}/.wm/playerctl.sh" play-pause
    fi
  fi
}

music-play() {
  if [ -f "$MUSIC_STATE" ]; then
    remove-music-state
    if [ "$DEBUG" -eq 1 ]; then
      log debug "Resuming music"
    else
      "${HOME}/.wm/playerctl.sh" play-pause
    fi
  fi
}

audio-set-mute() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Muting audio (microphone and speakers)"
  else
    wpctl set-mute @DEFAULT_AUDIO_SINK@ "$1"
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ "$1"
  fi
}

fingerprint-verify() {
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
    sway)
      swaylock -f -c 000000
      fingerprint-verify "swaylock"
      ;;
    i3)
      i3lock --nofork --ignore-empty-password --color=000000 &
      fingerprint-verify "i3lock"
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

wmmsg() {
  if [ "$DEBUG" -eq 1 ]; then
    log debug "Sending message to window manager (wmmsg): $@"
  else
    case "$DE" in
      sway)
        swaymsg "$@"
        ;;
      i3)
        i3-msg "$@"
        ;;
    esac
  fi
}

same-wifi() {
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


DE="$(get_desktop_environment)"

if [ "$DE" != "sway" -a "$DE" == "i3" ]; then
  log error "Unsupported desktop environment for screen locking."
  exit 1
fi

# fprintd
for cmd in playerctl wpctl jq nmcli; do
  if ! command_exists "$cmd"; then
    log error "The command '${cmd}' is missing. Please install it."
    exit 1
  fi
done

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
    same-wifi "$lock_type"

    wmmsg "output * dpms off"
    ;;
  resume)
    wmmsg "output * dpms on"
    audio-set-mute "0"
    ;;
  *)
    log error "Invalid option. Usage: lock | lock-soft | off | resume"
    ;;
esac

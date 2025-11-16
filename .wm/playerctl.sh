#!/usr/bin/env bash

command_exists() {
  if ! command -v "$1" > /dev/null; then
    log error "The command '${1}' is missing. Please install it."
    exit 1
  fi
}

mpc() {
  docker container exec -t mpd mpc "$@" 2> /dev/null
}

select_player() {
  local PLAYER_CMD="playerctl"

  if [ "$(mpc status | grep -ic "playing")" -eq 1 ]; then
    PLAYER_CMD="mpc"
  fi

  echo "$PLAYER_CMD"
}

player() {
  local PLAYER_CMD="$(select_player)"

  case "${PLAYER_CMD}" in
    mpc)
      case "$1" in
        status)
          if [ "$(mpc status | grep -ic "playing")" -eq 1 ]; then
            echo "playing"
          else
            echo "paused"
          fi
        ;;
        play-pause)
          if [ "$(mpc status | grep -ic "playing")" -eq 1 ]; then
            mpc -q stop
          else
            mpc -q play
          fi
        ;;
        prev)
          mpc -q prev
        ;;
        next)
          mpc -q next
      esac
    ;;
    playerctl)
      case "$1" in
        status)
          if [ "$(playerctl status | grep -ic "playing")" -eq 1 ]; then
            echo "playing"
          else
            echo "paused"
          fi
        ;;
        play-pause)
          playerctl play-pause
        ;;
        prev)
          playerctl previous
        ;;
        next)
          playerctl next
      esac
  esac
}


for cmd in playerctl; do
  command_exists "$cmd"
done

player "$1"

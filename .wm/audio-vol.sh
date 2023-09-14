#!/usr/bin/env bash
set -eo pipefail

. "${HOME}/.local/lib/sound.sh"


sinks="$(audio_device_get "Sink")"
sources="$(audio_device_get "Source")"

# Sink device id
headphone_connected="$(is_headphone_connected "$sinks")"

sink_device_id="$(echo "$sinks" | awk -F':' '{ print $1 }')"
if [ "$headphone_connected" == "true" ]; then
  sink_device_id="$(echo "$sinks" | awk -F':' '{ print $2 }')"
fi

# Source device id
source_device_id="$(echo "$sources" | awk -F':' '{ print $1 }')"
if [ "$headphone_connected" == "true" ]; then
  source_device_id="$(echo "$sources" | awk -F':' '{ print $2 }')"
fi

case "$1" in
  set)
    vol_set "$sink_device_id" "$2"
  ;;
  plus)
    vol_plus "$sink_device_id"
  ;;
  minus)
    vol_minus "$sink_device_id"
  ;;
  toggle)
    vol_mute_toggle "$sink_device_id"
  ;;
  micmute)
    vol_mute "$source_device_id"
  ;;
  micunmute)
    vol_unmute "$source_device_id"
  ;;
  mictoggle)
    vol_mute_toggle "$source_device_id"
  ;;
esac

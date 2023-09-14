
# set max allowed volume; 1.0 = 100%
VOL_MAX="1.0"
VOL_STEP="0.02"

audio_device_get() {
  local dtype="$1"

  devices="$(wpctl status | grep -A 20 "^Audio" | grep -A 3 "${dtype}s" | grep -P "^ │\s+\*?\s+\d{2}" | sed -e 's/│//' -e 's/\*//' | awk '{ print $1 }' | sed 's/\.//')"

  device_id_internal="$(echo "$devices" | head -n 1)"
  if [ "$(echo "$devices" | wc -l)" -eq 2 ]; then
    device_id_headphone="$(echo "$devices" | tail -n 1)"
  fi

  echo "${device_id_internal}:${device_id_headphone}"
}

is_headphone_connected() {
  local result="false"

  if [ "$(echo "$1" | grep -Pc "\d{2,3}:\d{2,3}")" -gt 0 ]; then
    result="true"
  fi

  echo "$result"
}

vol_get() {
  local device_id="$1"

  wpctl get-volume "$device_id" | awk '{ print $2 }'
}

vol_set() {
  local device_id="$1"
  local vol="$2"

  wpctl set-volume "$device_id" "${1}%"
}

vol_plus() {
  local device_id="$1"

  wpctl set-volume "$device_id" "${VOL_STEP}+" -l "$VOL_MAX"
}

vol_minus() {
  local device_id="$1"

  wpctl set-volume "$device_id" "${VOL_STEP}-"
}

is_muted() {
  local device_id="$1"
  local result="false"

  if [ "$(wpctl get-volume "$device_id" | grep -c "MUTED")" -eq 1 ]; then
    result="true"
  fi

  echo "$result"
}

vol_mute() {
  local device_id="$1"

  wpctl set-mute "$device_id" 0
}

vol_unmute() {
  local device_id="$1"

  wpctl set-mute "$device_id" 1
}

vol_mute_toggle() {
  local device_id="$1"

  wpctl set-mute "$device_id" toggle
}

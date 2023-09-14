#!/usr/bin/env bash

CONFIG_FILE_PATH="${HOME}/.config/local/desktop.json"

kill_prog() {
  prog_pattern="$1"

  prog_pid="$(ps aux | grep -i "$prog_pattern" | awk '{ print $2 }' | tail -n 1)"
  if [ -n "$prog_pid" ]; then
    sudo kill "$prog_pid"
  fi
}


for prog in $(jq -r '.suspend.prog.kill[]' "$CONFIG_FILE_PATH"); do
  kill_prog "$prog"
done

sudo systemctl suspend-then-hibernate

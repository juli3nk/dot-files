#!/usr/bin/env bash

# Function to kill a program by its pattern
kill_prog() {
  prog_pattern="$1"

  # Check if pgrep finds the process
  prog_pid=$(pgrep -i "$prog_pattern" | tail -n 1)
  if [ -n "$prog_pid" ]; then
    echo "Killing process $prog_pattern with PID $prog_pid..."
    sudo kill "$prog_pid" && echo "Successfully killed $prog_pattern" || echo "Failed to kill $prog_pattern"
  fi
}

# Check if the 'suspend.prog.kill' array exists in the JSON
# for prog in $(jq -r '.suspend.prog.kill[]' "$CONFIG_FILE_PATH"); do
#   kill_prog "$prog"
# done
programs_to_kill=$(jq -r '.suspend.prog.kill // empty' "$CONFIG_FILE_PATH")

# If no programs are found, exit early
if [ -z "$programs_to_kill" ]; then
  echo "No programs to kill found in '$CONFIG_FILE_PATH'."
else
  # Kill the listed programs
  for prog in $(echo "$programs_to_kill" | jq -r '.[]'); do
    kill_prog "$prog"
  done
fi

# Suspend and then hibernate the system
sudo systemctl suspend-then-hibernate


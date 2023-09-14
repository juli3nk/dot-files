#!/usr/bin/env bash
set -eo pipefail

set_device_reserved_block() {
  local device="$1"
  local reserved_block_percent="$2"

  # Change the count of reserved blocks on the device
  sudo tune2fs -r "$reserved_block_percent" "$device"

  # Display the reserved block count to verify the change
  sudo tune2fs -l "$device" | grep 'Reserved block count'
}


# Get the root device (the device mounted at "/")
root_device="$(lsblk -p -o NAME,MOUNTPOINT,UUID -r | awk '$2 == "/" { print $1 }')"
current_reserved_block="$(sudo tune2fs -l "$root_device" | awk '/^Reserved block count:/ { print $NF }')"

# Change the percentage of reserved blocks to 0% on the root device
set_device_reserved_block "$root_device" 0

# Securely wipe deleted files by overwriting free space with random data
sudo sfill -vfllz /

# Create a small zero-filled file of 100 MB
dd if=/dev/zero of=zero.small.file bs=1024 count=102400

# Create a zero-filled file until the disk space is exhausted
dd if=/dev/zero of=zero.file bs=1024

# Force writing of the buffered data to disk and wait to ensure all writes are complete
sync ; sleep 60 ; sync

# Remove the created files
rm zero.small.file
rm zero.file

# Restore the count of reserved blocks on the root device
set_device_reserved_block "$root_device" "$current_reserved_block"

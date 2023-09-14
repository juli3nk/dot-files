#!/usr/bin/env bash
set -eo pipefail

root_device="$(lsblk -p -o NAME,MOUNTPOINT,UUID -r | awk '$2 == "/" { print $1 }')"

sudo tune2fs -m 0 "$root_device"
sudo tune2fs -l "$root_device" | grep 'Reserved block count'

sudo sfill -vfllz /

dd if=/dev/zero of=zero.small.file bs=1024 count=102400
dd if=/dev/zero of=zero.file bs=1024
sync ; sleep 60 ; sync
rm zero.small.file
rm zero.file

sudo tune2fs -m 5 "$root_device"
sudo tune2fs -l "$root_device" | grep 'Reserved block count'

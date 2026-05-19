#!/usr/bin/env bash

MEM_16GB="16384"
MEM_EXTRA_16GB="3072"

MEM_32GB="32768"
MEM_EXTRA_32GB="6144"


if [ "$(grep -c "ID=ubuntu" /etc/os-release)" -eq 0 ]; then
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  echo -e "do not execute this script as root"
  exit 1
fi

if [ "$(grep -c "disk" /sys/power/state)" -eq 0 ]; then
  echo "hibernate is not supported"
  exit 1
fi

if [ "$(grep -c "RESUME" /etc/default/grub)" -gt 0 ]; then
  echo "hibernate seems to be already configured"
  exit 1
fi

SWAP_TYPE="$(swapon -s | tail -n 1 | awk '{ print $2 }')"

if [ "$SWAP_TYPE" == "file" ]; then
  DISK_TYPE="$(mount | awk '/on \/ type/ { print $5 }')"

  SWAP_PATH="/swapfile"
  if [ "$(grep -c "swap" /etc/fstab)" -eq 1 ]; then
    SWAP_PATH="$(awk '/swap/ { print $1 }' /etc/fstab)"
  fi
else
  DISK_TYPE="swap"
fi

mem_size="$(free -m | awk '/^Mem/ { print $2 }')"
swap_size="$(free -m | awk '/^Swap/ { print $2 }')"

if [ "$mem_size" -gt "$(echo "${MEM_16GB} / 1.10" | bc | awk -F'.' '{ print $1 }')" ] && [ "$mem_size" -lt "$(echo "${MEM_16GB} * 1.10" | bc | awk -F'.' '{ print $1 }')" ]; then
  SWAP_SIZE="$((MEM_16GB + MEM_EXTRA_16GB))"
elif [ "$mem_size" -gt "$(echo "${MEM_32GB} / 1.10" | bc | awk -F'.' '{ print $1 }')" ] && [ "$mem_size" -lt "$(echo "${MEM_32GB} * 1.10" | bc | awk -F'.' '{ print $1 }')" ]; then
  SWAP_SIZE="$((MEM_32GB + MEM_EXTRA_32GB))"
else
  echo "cannot guess memory size"
  exit 1
fi

if [ "$SWAP_TYPE" == "file" -a "$(echo "${swap_size} * 1.10" | bc | awk -F'.' '{ print $1 }')" -lt "$SWAP_SIZE" ]; then
  if [ "$(grep -c "swap" /etc/fstab)" -eq 0 ]; then
    echo -e "${SWAP_PATH}\t\tnone\t\tswap\tsw\t0\t0" | sudo tee -a /etc/fstab
  fi

  sudo swapoff "$SWAP_PATH"

  sudo dd if=/dev/zero of="$SWAP_PATH" bs=1MB count="$SWAP_SIZE" status=progress
  sudo chmod 600 "$SWAP_PATH"
  sudo mkswap "$SWAP_PATH"
  sudo swapon "$SWAP_PATH"
fi

swap_device_uuid="$(blkid -t TYPE="${DISK_TYPE}" -s UUID -o value)"

GRUB_RESUME_OPTS="resume=UUID=${swap_device_uuid}"
INITRAMFS_RESUME_OPTS="RESUME=UUID=${swap_device_uuid}"
if [ "$SWAP_TYPE" == "file" ]; then
  SWAP_FILE_PHYSICAL_OFFSET="$(sudo filefrag -v "$SWAP_PATH" | awk '/^ +0:/ { print $4 }' | sed 's/..$//')"
  SWAP_FILE_RESUME_OFFSET="resume_offset=${SWAP_FILE_PHYSICAL_OFFSET}"

  GRUB_RESUME_OPTS+=" $SWAP_FILE_RESUME_OFFSET"
  INITRAMFS_RESUME_OPTS+=" $SWAP_FILE_RESUME_OFFSET"
fi

sudo sed -i "/GRUB_CMDLINE_LINUX_DEFAULT/s/\"\$/ $GRUB_RESUME_OPTS\"/" /etc/default/grub

sudo update-grub

echo "$INITRAMFS_RESUME_OPTS" | sudo tee /etc/initramfs-tools/conf.d/resume

# regenerate initramfs
sudo update-initramfs -c -k all

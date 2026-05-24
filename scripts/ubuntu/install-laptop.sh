#!/usr/bin/env bash

if [ "$(grep -c "ID=ubuntu" /etc/os-release)" -eq 0 ]; then
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  echo -e "do not execute this script as root"
  exit 1
fi

CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"

. "${CURRENT_DIR}/utils.sh"

## Fingerprint
configure_fingerprint() {
  if [ "$(grep -c "pam_fprintd.so" /etc/pam.d/common-auth)" -eq 0 ]; then
    echo -e "auth\tsufficient\t\tpam_fprintd.so" | sudo tee -a /etc/pam.d/common-auth
    sudo pam-auth-update
  fi
}

# Do not suspend when lid is closed
configure_laptop_lid() {
  sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=lock/' /etc/systemd/logind.conf
}

## OBS
install_obs() {
  sudo add-apt-repository ppa:obsproject/obs-studio
  sudo apt update
  sudo apt install --no-install-recommends --yes \
    obs-studio
}

install_bleachit() {
  if [ "$(dpkg -l | grep -c bleachbit)" -eq 0 ]; then
    bleachbit_url="https://www.bleachbit.org"
    bleachbit_package_file="/tmp/bleachbit.deb"
    bleachbit_package_url_path="$(curl -s "${bleachbit_url}/download/linux" | grep "$(lsb_release -d | sed 's/Description:\s*//')" | grep -oP 'href="\K[^"]+"')"

    curl -sfL "${bleachbit_url}/${bleachbit_package_url_path}" -o "$bleachbit_package_file"
    sudo apt install --yes "$bleachbit_package_file"
    rm -f "$bleachbit_package_file"
  fi
}

## Teams
install_teams() {
  sudo snap install teams-for-linux
}


# Install packages
sudo apt update
sudo apt install --no-install-recommends --yes \
  blueman \
  bluez \
  brightnessctl \
  fprintd \
  gimp \
  keepassxc \
  libpam-fprintd \
  libreoffice \
  libvirt0 \
  pavucontrol \
  pasystray \
  playerctl \
  udiskie

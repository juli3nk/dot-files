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

install_librewolf() {
  sudo extrepo enable librewolf
  sudo extrepo update librewolf

  sudo apt update
  sudo apt install --no-install-recommends --yes \
    librewolf
}

## VSCode
install_vscode() {
  if [ "$(dpkg -l | grep -c vscode)" -eq 0 ]; then
    vscode_package_file="/tmp/code.deb"

    curl -sfL 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -o "$vscode_package_file"
    sudo apt install --yes "$vscode_package_file"
    rm -f "$vscode_package_file"
  fi
}

## System certificates
configure_system_certificates() {
  declare -a app_certs=(
    "/usr/share/librewolf/libnssckbi.so"
  )

  firefox_rev="$(snap list | awk '/^firefox/ { print $3 }')"
  app_certs+=("/snap/firefox/${firefox_rev}/usr/lib/firefox/libnssckbi.so")

  for app in "${app_certs[@]}"; do
    sudo mv "$app" "${app}.bak"
    sudo ln -s /usr/lib/x86_64-linux-gnu/pkcs11/p11-kit-trust.so "$app"
  done
}


# Install GUI related apps
if [ "$(is_gui)" -eq 0 ]; then
  exit
fi

# Install packages
sudo apt update
sudo apt install --no-install-recommends --yes \
  alacritty \
  calibre \
  chromium-browser \
  evince \
  fbreader \
  firefox \
  imv \
  mate-polkit \
  p11-kit \
  scrot \
  secure-delete \
  snapd \
  thunar \
  thunar-archive-plugin \
  thunar-font-manager \
  thunar-volman \
  vlc \
  xarchiver \
  xdg-utils

if [ "$1" == "i3" ]; then
  sudo apt install --no-install-recommends --yes \
    i3-wm \
    i3lock \
    dunst \
    flameshot \
    redshift \
    suckless-tools \
    xclip \
    xsel \
    xss-lock
fi

if [ "$1" == "sway" ]; then
  sudo apt install --no-install-recommends --yes \
    sway \
    swayidle \
    swaylock \
    grimshot \
    mako-notifier \
    wlsunset \
    xdg-desktop-portal-wlr
fi

## Eww
#sudo apt install --no-install-recommends --yes \
#  libblkid-dev \
#  libffi-dev \
#  libglib2.0-dev \
#  libglib2.0-dev-bin \
#  libgtk-3-dev \
#  libmount-dev \
#  libpcre2-dev \
#  libpcre2-posix3 \
#  libpkgconf3

install_librewolf
install_vscode

## Desktop Entry eXecution
xdg_autostart_dir="/etc/xdg/autostart"
xdg_autostart_disabled_dir="${xdg_autostart_dir}/disabled"

mkdir "$xdg_autostart_disabled_dir"
declare -a desktop_entries=(
  "geoclue-demo-agent.desktop"
  "org.gnome.DejaDup.Monitor.desktop"
  "print-applet.desktop"
  "ubuntu-advantage-notification.desktop"
  "ubuntu-report-on-upgrade.desktop"
)

for de in "${desktop_entries[@]}"; do
  mv "${xdg_autostart_dir}/${de}" "$xdg_autostart_disabled_dir"
done

configure_system_certificates

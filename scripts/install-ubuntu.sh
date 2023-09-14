#!/usr/bin/env bash

if [ "$(grep -c "ID=ubuntu" /etc/os-release)" -eq 0 ]; then
  exit 1
fi

if [ $(id -u) -eq 0 ]; then
  echo -e "do not execute this script as root"
  exit 1
fi

# Set sudoers
SUDOERS_FILE_ME="/etc/sudoers.d/me"
rule="$(id -un) ALL=(ALL) NOPASSWD:ALL"

if [ ! -f "$SUDOERS_FILE_ME" ]; then
  sudo echo "$rule" > "$SUDOERS_FILE_ME"
fi

# APT keyrings
APT_KEYRINGS_PATH="/etc/apt/keyrings"

sudo install -m 0755 -d "$APT_KEYRINGS_PATH"

# Install packages
sudo apt update
sudo apt install --no-install-recommends --yes \
  alacritty \
  apt-transport-https \
  blueman \
  bluez \
  brightnessctl \
  btop \
  ca-certificates \
  calibre \
  chromium-browser \
  chrony \
  curl \
  evince \
  fbreader \
  firewalld \
  fprintd \
  firefox \
  gcc \
  gimp \
  git \
  gnupg \
  htop \
  imv \
  keepassxc \
  libfuse2 \
  libpam-fprintd \
  libreoffice \
  libvirt0 \
  make \
  mate-polkit \
  p11-kit \
  pavucontrol \
  pasystray \
  playerctl \
  pwgen \
  secure-delete \
  snapd \
  thunar \
  thunar-archive-plugin \
  thunar-font-manager \
  thunar-volman \
  tmux \
  udiskie \
  vlc \
  virtualbox \
  wget \
  xarchiver

if [ "$1" == "i3" ]; then
  sudo apt install --no-install-recommends --yes \
    i3-wm \
    i3lock \
    dunst \
    flameshot \
    redshift \
    suckless-tools \
    xclip \
    xss-lock
fi

if [ "$1" == "sway" ]; then
  sudo apt install --no-install-recommends --yes \
    sway \
    swayidle \
    swaylock \
    grimshot \
    mako-notifier \
    xdg-desktop-portal-wlr
fi

## Docker
if [ ! -f "${APT_KEYRINGS_PATH}/docker.gpg" ]; then
  curl -sfSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "${APT_KEYRINGS_PATH}/docker.gpg"
  sudo chmod a+r "${APT_KEYRINGS_PATH}/docker.gpg"
fi

if [ ! -f "/etc/apt/sources.list.d/docker.list" ]; then
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=${APT_KEYRINGS_PATH}/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt update
fi

sudo apt install --no-install-recommends --yes \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

## LibreWolf
if [ ! -f "${APT_KEYRINGS_PATH}/librewolf.gpg" ]; then
  curl -sfL https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o "${APT_KEYRINGS_PATH}/librewolf.gpg"
  sudo chmod a+r "${APT_KEYRINGS_PATH}/librewolf.gpg"
fi

distro=$(if echo " una bookworm vanessa focal jammy bullseye vera uma " | grep -q " $(lsb_release -sc) "; then echo $(lsb_release -sc); else echo focal; fi)

if [ ! -f "/etc/apt/sources.list.d/librewolf.sources" ]; then
  sudo tee /etc/apt/sources.list.d/librewolf.sources << EOF > /dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: $distro
Components: main
Architectures: amd64
Signed-By: ${APT_KEYRINGS_PATH}/librewolf.gpg
EOF

  sudo apt update
fi

sudo apt install --no-install-recommends --yes \
  librewolf

## VSCode
if [ "$(dpkg -l | grep -c vscode)" -eq 0 ]; then
  vscode_package_file="/tmp/code.deb"

  curl -sfL https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -o "$vscode_package_file"
  sudo apt install --yes "$vscode_package_file"
  rm -f "$vscode_package_file"
fi

## OBS
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt update
sudo apt install --no-install-recommends --yes \
  obs-studio

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

## BleachBit
if [ "$(dpkg -l | grep -c bleachbit)" -eq 0 ]; then
  bleachbit_url="https://www.bleachbit.org"
  bleachbit_package_file="/tmp/bleachbit.deb"
  bleachbit_package_url_path="$(curl -s "${bleachbit_url}/download/linux" | grep "$(lsb_release -d | sed 's/Description:\s*//')" | grep -oP 'href="\K[^"]+"')"

  curl -sfL "${bleachbit_url}/${bleachbit_package_url_path}" -o "$bleachbit_package_file"
  sudo apt install --yes "$bleachbit_package_file"
  rm -f "$bleachbit_package_file"
fi

## Teams
sudo snap install teams-for-linux


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


## Fingerprint
if [ "$(grep -c "pam_fprintd.so" /etc/pam.d/common-auth)" -eq 0 ]; then
  echo -e "auth\tsufficient\t\tpam_fprintd.so" | sudo tee -a /etc/pam.d/common-auth
  sudo pam-auth-update
fi

# Do not suspend when lid is closed
sudo sed -i 's/#HandleLidSwitch=suspend/HandleLidSwitch=lock/' /etc/systemd/logind.conf

## System certificates
declare -a app_certs=(
  "/usr/share/librewolf/libnssckbi.so"
)

firefox_rev="$(snap list | awk '/^firefox/ { print $3 }')"
app_certs+=("/snap/firefox/${firefox_rev}/usr/lib/firefox/libnssckbi.so")

for app in "${app_certs[@]}"; do
  sudo mv "$app" "${app}.bak"
  sudo ln -s /usr/lib/x86_64-linux-gnu/pkcs11/p11-kit-trust.so "$app"
done

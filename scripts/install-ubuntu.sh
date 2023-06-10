#!/usr/bin/env bash

apt update
apt install --no-install-recommends --yes \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    gnupg \
    htop \
    neovim \
    tmux \
    wget \

    sway \
    grimshot \
    alacritty \
    udiskie \
    bluez* \
    blueman \
    thunar \
    keepassxc \
    libreoffice \
    pavucontrol \
    pasystray \
    firefox \
    chromium-browser \
    vlc \
    pidgin

curl -sSL https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -o /tmp/code.deb
apt install --yes /tmp/code.deb
rm -f /tmp/code.deb


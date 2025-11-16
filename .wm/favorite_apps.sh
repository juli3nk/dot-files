#!/usr/bin/env bash

list_favorites() {
  echo -e "FileManager\nKeePassXC\nLibreWolf\nFirefox\nChromium\nLibreOffice\nDicoFR\nConjugaisonFR"
}

choice=$(list_favorites | fuzzel --dmenu --prompt "Select favorite")

case "$choice" in
  FileManager)
    exec thunar
    ;;
  KeePassXC)
    exec keepassxc
    ;;
  LibreWolf)
    exec librewolf
    ;;
  Firefox)
    exec systemd-run --user --scope -p MemoryMax=8G -p CPUQuota=50% firefox
    ;;
  Chromium)
    exec chromium
    ;;
  LibreOffice)
    exec libreoffice
    ;;
  DicoFR)
    exec firefox --new-tab https://fr.wiktionary.org
    ;;
  ConjugaisonFR)
    exec firefox --new-tab http://www.conjugaison.com
    ;;
  *)
    exit 1
esac

exit 0

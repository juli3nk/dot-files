#!/usr/bin/env bash

list_favorites() {
  echo -e "FileManager\nKeePassXC\nFirefox\nChromium\nLibreOffice\nTranslate\nDicoFR\nConjugaisonFR"
}

FAVORITE=$(list_favorites | rofi -dmenu -p "Select favorite")

case ${FAVORITE} in
FileManager)
  exec thunar
  ;;
KeePassXC)
  exec keepassxc
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
Translate)
  exec firefox --new-tab https://deepl.com
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

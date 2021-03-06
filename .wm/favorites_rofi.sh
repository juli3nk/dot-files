#!/usr/bin/env bash

list_favorites() {
	echo -e "FileManager\nKeePassXC\nFirefox\nThunderbird\nGmail\nVSCodium\nMusic\nLibreOffice\nEditor\nTranslate\nDicoFR\nConjugaisonFR"
}

FAVORITE=$(list_favorites | rofi -dmenu -p "Select favorite")

case ${FAVORITE} in
FileManager)
	exec caja
	;;
KeePassXC)
	exec keepassxc
	;;
Firefox)
	exec firefox
	;;
Thunderbird)
	exec thunderbird
	;;
Gmail)
	exec firefox --new-window https://gmail.com
	;;
VSCodium)
	exec codium --enable-proposed-api ms-vscode-remote.remote-containers,ms-vscode-remote.remote-ssh,ms-vscode-remote.remote-wsl
	;;
Music)
	#exec firefox --new-window https://spotify.com
	exec spotify
	;;
LibreOffice)
	exec libreoffice
	;;
Editor)
	exec gedit
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

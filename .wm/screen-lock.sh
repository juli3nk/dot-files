#!/usr/bin/env bash

MUSIC_STATE="/tmp/music-state"

create-music-state() {
	touch $MUSIC_STATE
}

remove-music-state() {
	rm -f $MUSIC_STATE
}

music-pause() {
	if [ $(./playerctl.sh status | grep "playing" | wc -l) -eq 1 ]; then
		create-music-state
		./playerctl.sh play-pause
	fi
}

music-play() {
	if [ -f "$MUSIC_STATE" ]; then
		remove-music-state
		./playerctl.sh play-pause
	fi
}

wmlock() {
	if [ $XDG_CURRENT_DESKTOP == "sway" ]; then
		swaylock -f -c 000000
	fi
	if [ $XDG_CURRENT_DESKTOP == "i3" ]; then
		i3lock -c 000000 -n
	fi
}
wmmsg() {
	if [ $XDG_CURRENT_DESKTOP == "sway" ]; then
		swaymsg $@
	fi
	if [ $XDG_CURRENT_DESKTOP == "i3" ]; then
		i3-msg $@
	fi
}

wifi=$(jq -r '. | .wifi.home' $HOME/.config/local-conf/config.json)

if [ $(nmcli c show --active | awk '/wifi/ { print $1 }') == $wifi -a $wifi != "none" ]; then
	exit
fi

if [ $(playerctl status) == "Playing" ]; then
	exit
fi

case "$1" in
	lock)
		remove-music-state
		music-pause
		wmlock
		;;
	lock-soft)
		wmlock
		;;
	off)
		wmmsg "output * dpms off"
		;;
	resume)
		wmmsg "output * dpms on"
		music-play
esac

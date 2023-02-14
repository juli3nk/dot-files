#!/usr/bin/env bash

wmmsg() {
	if [ $XDG_CURRENT_DESKTOP == "sway" ]; then
		swaymsg $@
	fi
	if [ $XDG_CURRENT_DESKTOP == "i3" ]; then
		i3-msg $@
	fi
}

wmmsg exit

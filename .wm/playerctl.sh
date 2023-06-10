#!/usr/bin/env bash

mpc() {
	docker container exec -t mpd mpc "$@" 2> /dev/null
}

select_player() {
	local PLAYER_CMD="playerctl"

	if [ $(mpc status | grep -ic "playing") -eq 1 ]; then
		PLAYER_CMD="mpc"
	fi

	echo $PLAYER_CMD
}

player() {
	local PLAYER_CMD=$(select_player)

	case "${PLAYER_CMD}" in
		mpc)
			case "$1" in
				status)
					if [ $(mpc status | grep "playing" | wc -l) -eq 1 ]; then
						echo "playing"
					else
						echo "paused"
					fi
				;;
				play-pause)
					if [ $(mpc status | grep "playing" | wc -l) -eq 1 ]; then
						mpc -q stop
					else
						mpc -q play
					fi
				;;
				prev)
					mpc -q prev
				;;
				next)
					mpc -q next
			esac
		;;
		playerctl)
			case "$1" in
				status)
					if [ $(playerctl status | grep -ic "playing") -eq 1 ]; then
						echo "playing"
					else
						echo "paused"
					fi
				;;
				play-pause)
					playerctl play-pause
				;;
				prev)
					playerctl previous
				;;
				next)
					playerctl next
			esac
	esac
}

player "$1"

exit 0

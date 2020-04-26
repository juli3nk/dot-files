#!/usr/bin/env bash

STATE_FILE="/tmp/audio-profile.state"

cd $HOME/.wm

case "$1" in
    call)
        if [ $(./playerctl.sh status | grep "playing" | wc -l) -eq 1 ]; then
            ./playerctl.sh play-pause
            ./pa-vol.sh set 50
            ./pa-vol.sh micunmute
        else
            ./pa-vol.sh micmute
            ./pa-vol.sh set 31
            ./playerctl.sh play-pause
        fi
esac

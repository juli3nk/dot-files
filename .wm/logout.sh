#!/usr/bin/env bash

. "${HOME}/.local/lib/de.sh"


DE="$(get_desktop_environment)"
is_desktop_environment_supported "$DE"

wmmsg "$DE" exit

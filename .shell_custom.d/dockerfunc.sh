# Bash wrappers for docker run commands

#
# Apps
#
devgo() {
  # --mount type=bind,src=${SSH_AUTH_SOCK},dst=${SSH_AUTH_SOCK},ro \
  # -e "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" \
  local privileged
  if [ "$1" == "privileged" ]; then
    privileged="--privileged"
  fi
  local mountdst
  mountdst="/go/src/github.com/$(echo "$PWD" | awk 'BEGIN { FS="/"; OFS="/" } { print $(NF-1), $NF }')"

  docker container run \
    -ti \
    --rm $privileged \
    --mount type=bind,src="${PWD}",dst="$mountdst" \
    --mount type=bind,src="${HOME}/.gitconfig",dst=/root/.gitconfig,ro \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --workdir "$mountdst" \
    juli3nk/dev:go
}
dockerlint() {
  docker container run \
    -i \
    --rm \
    hadolint/hadolint < "$@"
}
hdu() {
  docker container run \
    -t \
    --rm \
    --mount type=bind,src="${HOME}/Dev/juli3nk/home-dns-data/data.yml",dst=/tmp/data.yml,ro \
    juli3nk/home-dns-update "$@"
}
htpasswd() {
  docker container run \
    -ti \
    --rm \
    jessfraz/htpasswd "$@"
}
mpc() {
  docker container exec -t mpd mpc "$@"
}
mpd() {
  docker container run \
    -d \
    --rm \
    --mount type=bind,src="${HOME}/.config/mpd",dst=/home/user/.config/mpd \
    --device /dev/snd \
    --env PULSE_SERVER="unix:${XDG_RUNTIME_DIR}/pulse/native" \
    --mount type=bind,src="${XDG_RUNTIME_DIR}/pulse/native",dst="${XDG_RUNTIME_DIR}/pulse/native" \
    --mount type=bind,src="${HOME}/.config/pulse/cookie",dst=/home/user/.config/pulse/cookie \
    --name mpd \
    juli3nk/mpd
}
shellcheck() {
  docker container run \
    -t \
    --rm \
    --mount type=bind,src="${PWD}",dst=/mnt,ro \
    koalaman/shellcheck "$@"
}
shfmt() {
  docker container run \
    -t \
    --rm \
    --mount type=bind,src="${PWD}",dst=/mnt,ro \
    juli3nk/shfmt "$@"
}

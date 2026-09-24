# Bash wrappers for docker run commands

#
# Apps
#
dockerlint() {
  docker container run \
    -i \
    --rm \
    hadolint/hadolint < "$@"
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
ollama_server() {
  local image="ollama/ollama"
  local data_dir="${HOME}/Data/ollama"

  mkdir -p "$data_dir"
  docker image pull "$image"
  docker container run \
    -d \
    --rm \
    --mount type=bind,src="$data_dir",dst=/root/.ollama \
    -p 11434:11434 \
    --name ollama \
    "$image"
}
ollama() {
  docker container exec \
    -ti \
    ollama "$@"
}
open_webui() {
  #     -e OLLAMA_BASE_URL=http://192.168.1.97:11434 \
  local image="ghcr.io/open-webui/open-webui:main"
  local data_dir="${HOME}/Data/open-webui"

  mkdir -p "$data_dir"
  docker image pull "$image"
  docker container run \
    -d \
    --rm \
    --mount type=bind,src="$data_dir",dst=/app/backend/data \
    -p 3000:8080 \
    --name open-webui \
    "$image"
}

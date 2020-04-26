# Bash wrappers for docker run commands

#
# Helper Functions
#
dcleanup() {
	local containers
	mapfile -t containers < <(docker container ls -aq 2>/dev/null)
	docker container rm "${containers[@]}" 2>/dev/null
	local volumes
	mapfile -t volumes < <(docker container ls --filter status=exited -q 2>/dev/null)
	docker container rm -v "${volumes[@]}" 2>/dev/null
	local images
	mapfile -t images < <(docker image ls --filter dangling=true -q 2>/dev/null)
	docker image rm "${images[@]}" 2>/dev/null
}
relies_on() {
	for container in "$@"; do
		local state
		state=$(docker container inspect --format "{{.State.Running}}" "$container" 2>/dev/null)

		if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
			echo "$container is not running, starting it for you."
			$container
		fi
	done
}

#
# Apps
#
convert() {
        docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/tmp/workspace \
		--workdir /tmp/workspace \
                juli3nk/imagemagick convert "$@"
}
identify() {
        docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/tmp/workspace \
		--workdir /tmp/workspace \
                juli3nk/imagemagick identify "$@"
}
devgo() {
		# --mount type=bind,src=${SSH_AUTH_SOCK},dst=${SSH_AUTH_SOCK},ro \
		# -e "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" \
	echo $1
	local privileged=""
	if [ "$1" = "privileged" ]; then
		privileged="--privileged"
	fi
	local mountdst="/go/src/github.com/$(echo $PWD | awk 'BEGIN { FS="/"; OFS="/" } { print $(NF-1), $NF }')"

	docker container run -ti \
		--rm $privileged \
		--mount type=bind,src=${PWD},dst=$mountdst \
		--mount type=bind,src=${HOME}/.gitconfig,dst=/root/.gitconfig,ro \
		--workdir $mountdst \
		juli3nk/dev:go
}
dockerlint() {
	docker container run -i \
		--rm \
		hadolint/hadolint < "$@"
}
#doctl() {
#        docker container run -ti \
#		--rm \
#		--env "DIGITALOCEAN_ACCESS_TOKEN=${DIGITALOCEAN_ACCESS_TOKEN}" \
#		digitalocean/doctl "$@"
#}
gofmt() {
	docker container run -t \
		--rm \
		--mount type=bind,src=${PWD},dst=/tmp/workspace \
		--workdir /tmp/workspace \
		golang:1.16-alpine3.13 gofmt "$@"
}
hdu() {
	docker container run -t \
		--rm \
		--mount type=bind,src=${HOME}/Dev/juli3nk/home-dns-data/data.yml,dst=/tmp/data.yml,ro \
		juli3nk/home-dns-update "$@"
}
htpasswd() {
	docker container run -ti \
		--rm \
		jessfraz/htpasswd "$@"
}
mpd() {
	docker container run -d \
		--rm \
		--mount type=bind,src=${HOME}/.config/mpd,dst=/home/user/.config/mpd \
		--device /dev/snd \
		-e PULSE_SERVER=unix:${XDG_RUNTIME_DIR}/pulse/native \
		-v ${XDG_RUNTIME_DIR}/pulse/native:${XDG_RUNTIME_DIR}/pulse/native \
		-v ${HOME}/.config/pulse/cookie:/home/user/.config/pulse/cookie \
		--name mpd \
		juli3nk/mpd
}
mpc() {
	docker container exec -t mpd mpc "$@"
}
netcat() {
	docker container run -ti \
		--rm \
		--net host \
		jessfraz/netcat "$@"
}
nmap() {
	docker container run -ti \
		--rm \
		--net host \
		jessfraz/nmap "$@"
}
packer() {
	docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/tmp/project \
		-w /tmp/project \
		hashicorp/packer:light "$@"
}
postman() {
	local docker_user="$(id -u):$(id -g)"
	local homedir="/home/$(id -un)"

	xhost +
	docker container run -d \
		--rm \
		--mount type=bind,src=/etc/localtime,dst=/etc/localtime,ro \
		--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--user ${docker_user} \
		--mount type=bind,src=/etc/passwd,dst=/etc/passwd,ro \
		--mount type=bind,src=/etc/group,dst=/etc/group,ro \
		--mount type=bind,src=${homedir},dst=${homedir} \
		--net host \
		--name postman \
		juliengk/postman "$@"
}
shellcheck() {
	docker container run -t \
		--rm \
		--mount type=bind,src=${PWD},dst=/mnt,ro \
		koalaman/shellcheck "$@"
}
stepca() {
	docker container run -d \
		--rm \
		--mount type=bind,src=${HOME}/Dev/juli3nk/home-ca-intermediate,dst=/home/step \
		smallstep/step-cli step ca "$@"
}
cwebp() {
        docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/tmp/workspace \
		-w /tmp/workspace \
                juliengk/webp cwebp "$@"
}
vwebp() {
        docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/tmp/workspace \
		--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-w /tmp/workspace \
                juliengk/webp vwebp "$@"
}
wireshark() {
	docker container run -d \
		--rm\
		--mount type=bind,src=/etc/localtime,dst=/etc/localtime,ro \
		--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--cap-add NET_RAW \
		--cap-add NET_ADMIN \
		--net host \
		--name wireshark \
		jessfraz/wireshark
}
#yq() {
#	docker container run -ti \
#		--rm \
#		--mount type=bind,src=${PWD},dst=/workdir \
#		mikefarah/yq yq "$@"
#}

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
az() {
	local docker_user="$(id -u):$(id -g)"
	local homedir="/home/$(id -un)"

	docker container run -ti \
		--rm \
		--mount type=bind,src=/etc/passwd,dst=/etc/passwd,ro \
		--mount type=bind,src=/etc/group,dst=/etc/group,ro \
		--mount type=bind,src=${homedir},dst=${homedir} \
		--env "AZURE_STORAGE_ACCOUNT=${AZURE_STORAGE_ACCOUNT}" \
		--env "AZURE_STORAGE_KEY=${AZURE_STORAGE_KEY}" \
		--user ${docker_user} \
		mcr.microsoft.com/azure-cli az "$@"
}
convert() {
        docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/tmp/workspace \
		-w /tmp/workspace \
                juli3n/imagemagick convert "$@"
}
devgo() {
	local mountdst="/go/src/github.com/$(echo $PWD | awk 'BEGIN { FS="/"; OFS="/" } { print $(NF-1), $NF }')"

	docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=$mountdst \
		--mount type=bind,src=${HOME}/.gitconfig,dst=/root/.gitconfig,ro \
		--mount type=bind,src=${SSH_AUTH_SOCK},dst=${SSH_AUTH_SOCK},ro \
		-e "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}" \
		-w $mountdst \
		juliengk/dev:go
}
dig() {
	docker container run -ti \
		--rm \
		--log-driver none \
		juliengk/dig "$@"
}
dockerlint() {
	docker container run -i \
		--rm \
		hadolint/hadolint < "$@"
}
doctl() {
        docker container run -ti \
		--rm \
		--env "DIGITALOCEAN_ACCESS_TOKEN=${DIGITALOCEAN_ACCESS_TOKEN}" \
		digitalocean/doctl "$@"
}
evans() {
	docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/tmp/workspace \
		--workdir /tmp/workspace \
		juliengk/evans "$@"
}
gmailfilters() {
	docker container run -t \
		--rm \
		--mount type=bind,src=${HOME}/.config/google/creds/gmail.json,dst=/tmp/creds.json,ro \
		--mount type=bind,src=${HOME}/.config/google/token/gmail.json,dst=/tmp/token.json \
		--mount type=bind,src=${PWD},dst=/tmp/filters \
		-w /tmp/filters \
		jessfraz/gmailfilters "$@"
}
htop() {
	docker container run -ti \
		--rm \
		--pid host \
		--net none \
		--name htop \
		jessfraz/htop
}
htpasswd() {
	docker container run -ti \
		--rm \
		jessfraz/htpasswd "$@"
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
# puppet template syntax checking
pt() {
	if [ -z "$1" ]; then
		echo "usage: pt <puppet_template_file.erb>"
		return;
	fi

	docker container run -t \
		--rm \
		--mount type=bind,src=${PWD},dst=/mnt,ro \
		puppet/puppet-agent erb -P -x -T '-' $1 | /usr/bin/ruby -c
}
puppet() {
	docker container run -t \
		--rm \
		--mount type=bind,src=${PWD},dst=/mnt,ro \
		puppet/puppet-agent puppet "$@"
}
# puppet manifest syntax checking
alias pc="puppet parser validate $@"
shellcheck() {
	docker container run -t \
		--rm \
		--mount type=bind,src=${PWD},dst=/mnt,ro \
		koalaman/shellcheck "$@"
}
signal_desktop() {
	xhost +
	docker container run -d \
		--rm \
		--mount type=bind,src=/etc/localtime,dst=/etc/localtime,ro \
		--mount type=bind,src=/etc/passwd,dst=/etc/passwd,ro \
		--mount type=bind,src=/etc/group,dst=/etc/group,ro \
		--mount type=bind,src=${HOME},dst=/home/signal \
		--mount type=bind,src=/tmp/.X11-unix,dst=/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--cap-add SYS_ADMIN \
		--name signal_desktop \
		juliengk/signal-desktop "$@"
}
alias signal-desktop='signal_desktop'
syncthing() {
	mkdir -p $HOME/Data/syncthing/{config,Data}

	docker container run -d \
		--rm \
		--mount type=bind,src=$HOME/Data/syncthing/config,dst=/var/syncthing/config \
		--mount type=bind,src=$HOME/Data/syncthing/Data,dst=/var/syncthing/Data \
		-e "PGID=$(id -g)" \
		--name syncthing \
		syncthing/syncthing

	firefox --new-tab https://$(docker container inspect -f '{{ .NetworkSettings.IPAddress }}' syncthing):8384
}
telnet() {
	docker container run -ti \
		--rm \
		--log-driver none \
		jessfraz/telnet "$@"
}
terraform() {
	env | grep -E "^TF_" > tmp.env

	docker container run -ti \
		--rm \
		--env-file tmp.env \
		--mount type=bind,src=${PWD},dst=/tmp/project \
		-w /tmp/project \
		hashicorp/terraform:light "$@"
}
traceroute() {
	docker container run -ti \
		--rm \
		--net host \
		jessfraz/traceroute "$@"
}
travis() {
	docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/srv/project \
		--mount type=bind,src=${HOME}/Data/travis/home,dst=/root/.travis \
		juliengk/travis "$@"
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
yq() {
	docker container run -ti \
		--rm \
		--mount type=bind,src=${PWD},dst=/workdir \
		mikefarah/yq yq "$@"
}

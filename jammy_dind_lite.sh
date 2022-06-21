#!/bin/bash

set -o pipefail
set -o functrace

RED=$(tput setaf 1)
YELLOW=$(tput setaf 2)
RESET=$(tput sgr0)
DESC="Script Description"

trap '__trap_error $? $LINENO' ERR 2>&1

function __trap_error() {
	echo "Error! Exit code: $1 - On line $2"
}

function help() {
	me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
	echo
	echo $DESC
	echo
	echo "List of functions in $YELLOW$me$RESET script: "
	echo
	list=$(declare -F | awk '{print $NF}' | sort | egrep -v "^_")
	for i in ${list[@]}
	do
		echo "Usage: $YELLOW./$me$RESET$RED $i $RESET"
	done
	echo
}

IMAGE="ghcr.io/manprint/ubuntu-dind-jammy-light:latest-v1"
CONTAINER="jammy_dind_lite"
HOSTNAME="ubuntu-lite"

function __mkdir() {
	mkdir -vp $(pwd)/data/ubuntu
	mkdir -vp $(pwd)/data/docker
}

function __volume() {
	docker volume create \
		--driver local \
		--opt type=none \
		--opt device=$(pwd)/data/ubuntu \
		--opt o=bind \
		vol_${CONTAINER}_ubuntu
	docker volume create \
		--driver local \
		--opt type=none \
		--opt device=$(pwd)/data/docker \
		--opt o=bind \
		vol_${CONTAINER}_docker
}

function down() {
	docker stop ${CONTAINER}
	docker rm ${CONTAINER}
	docker volume rm vol_${CONTAINER}_ubuntu vol_${CONTAINER}_docker
}

function up() {
	down
	__mkdir
	__volume
	docker run -d \
		--privileged \
		--name=${CONTAINER} \
		--hostname=${HOSTNAME} \
		--publish=2375:2375/tcp \
		--volume=vol_${CONTAINER}_docker:/var/lib/docker \
		--volume=vol_${CONTAINER}_ubuntu:/home/ubuntu \
		${IMAGE}
}

if [ "_$1" = "_" ]; then
	help
else
	"$@"
fi

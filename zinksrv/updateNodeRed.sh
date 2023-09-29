#!/bin/bash

function main() {
  #pull-image
  #create-pod
  #create-systemd-service
  update
}

function create-pod() {
  # https://nodered.org/docs/getting-started/docker
  #mkdir -p /local/data/$(hostname -s)/srv/${IMAGE_NAME}-data 
  #chown 1000:1000 /local/data/$(hostname -s)/srv/${IMAGE_NAME}-data
  #cmd="podman run -d --name=\"${IMAGE_NAME}\" --mount type=bind,source=\"/local/data/$(hostname -s)/srv/${IMAGE_NAME}\",target=\"/data\" --net=host ${IMAGE_REPO_URL}/${IMAGE_PATH}/${IMAGE_NAME}:${IMAGE_TAG}"
  cmd="podman run -d --name=\"${IMAGE_NAME}\" -v \"/local/data/$(hostname -s)/srv/${IMAGE_NAME}-data\":\"/data\" --net=host -e TZ=\"UTC+01:00\" ${IMAGE_REPO_URL}/${IMAGE_PATH}/${IMAGE_NAME}:${IMAGE_TAG}"
  echo $cmd
  eval $cmd
}

function pull-image() {
  podman pull ${IMAGE_REPO_URL}/${IMAGE_PATH}/${IMAGE_NAME}:${IMAGE_TAG}
} 

function create-systemd-service() {
  # https://www.tutorialworks.com/podman-systemd/
  podman generate systemd --new --name ${IMAGE_NAME} > /etc/systemd/system/${IMAGE_NAME}.service
  systemctl daemon-reload
  systemctl status ${IMAGE_NAME}.service
  systemctl enable ${IMAGE_NAME}.service
}

function update() {
  pull-image
  systemctl stop ${IMAGE_NAME}.service
  podman stop ${IMAGE_NAME}
  podman rm ${IMAGE_NAME}
  create-pod
  systemctl start ${IMAGE_NAME}.service
}

IMAGE_REPO_URL=registry.hub.docker.com
IMAGE_REPO_URL=docker.io
IMAGE_PATH=nodered
IMAGE_NAME=node-red
IMAGE_TAG=latest


if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
main $@





#!/bin/bash
function main() {
  update-homeassistant
}

function create-pod() {
  podman run -d \
    --name="home-assistant" \
    --mount type=bind,source="/local/data/$(hostname -s)/srv/home-assist/home-assistant-config",target=/config \
    -v /etc/localtime:/etc/localtime:ro \
    --net=host \
    homeassistant/home-assistant:stable
}

function pull-image() {
  podman pull homeassistant/home-assistant:stable
}  

function update-homeassistant() {
  pull-image
  systemctl stop home-assist.service
  podman stop home-assistant 
  podman rm home-assistant
  create-pod
  systemctl start home-assist.service
}

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
main $@


#!/bin/bash
SERVICE_NAME="vaultwarden"
CONTAINER_IMAGE="vaultwarden/server:latest"
DATA_DIR="/local/data/$(hostname -s)/srv/${SERVICE_NAME}"

source /links/bin/podmanFunctions.sh

function createPod() {
   podman run -d \
   --name=${SERVICE_NAME} \
   --net=host \
   -e ROCKET_PORT=8085 \
   -e DOMAIN=https://zinks.dnshome.de:44300/vaultwarden/ \
   -e ADMIN_TOKEN=WjkzK3ZhdWx0d2FyZGVuLWFkbWluLXRva2VuK1o5Mw== \
   -v /etc/localtime:/etc/localtime:ro \
   -v ${DATA_DIR}:/data \
   -e TZ=Europe/Amsterdam \
   ${CONTAINER_IMAGE}
}


# main
main $@

#!/bin/bash
SERVICE_NAME="caddy"
CONTAINER_IMAGE="caddy:latest"
DATA_DIR="/local/data/$(hostname -s)/srv/${SERVICE_NAME}"

source /links/bin/podmanFunctions.sh

function createConfig() {
   mkdir -p ${DATA_DIR}
   touch ${DATA_DIR}/Caddyfile
   mkdir -p ${DATA_DIR}/site
   mkdir -p ${DATA_DIR}/data
   mkdir -p ${DATA_DIR}/config
}

function createPod() {
   podman run \
      --name=${SERVICE_NAME} \
      --hostname=${SERVICE_NAME} \
      --net=host \
      -v ${DATA_DIR}/Caddyfile:/etc/caddy/Caddyfile \
      -v ${DATA_DIR}/site:/srv \
      -v ${DATA_DIR}/data:/data \
      -v ${DATA_DIR}/config:/config \
      -e TZ=Europe/Amsterdam \
      ${CONTAINER_IMAGE}
}


# main
main $@
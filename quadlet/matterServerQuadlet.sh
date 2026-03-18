#!/bin/bash
# see https://github.com/matter-js/python-matter-server

set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function CreateQuadlet() {
  mkdir -p ${MATTER_SERVER_DATA_DIR}
  chmod 777 -R ${MATTER_SERVER_DATA_DIR}
  # chown -R 65534:65534 ${MATTER_SERVER_DATA_DIR}
  # chcon -t container_file_t ${MATTER_SERVER_DATA_DIR}
  cat <<EOF > ${QUADLET_DIR}/${SERVICE_NAME}.container 
[Unit]
Description=${SERVICE_NAME}
Wants=network-online.target
After=network-online.target

[Container]
Label=app=${SERVICE_NAME}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=${SERVICE_NAME}
Image=${CONTAINER_IMAGE}
# Network=${NETWORK_NAME}
Network=host
PublishPort=${MATTER_SERVER_HTTP_PORT}:${MATTER_SERVER_HTTP_PORT}
Volume=${MATTER_SERVER_DATA_DIR}:/data
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam

[Service]
Restart=on-failure

[Install]
${START_ON_BOOT}
EOF
}

function setEnvVars() {
  setDefaultEnvVars
  SERVICE_NAME="matter-server"
  DATA_DIR="$(yq -r '.MATTER_SERVER.DATA_DIR' "${CONFIG_YAML}")"
  MATTER_SERVER_DATA_DIR="${DATA_DIR}/data"
  SERVER_IP=$(hostname -I | awk '{print $1}')
  MATTER_SERVER_HTTP_PORT="$(yq -r '.MATTER_SERVER.HTTP_PORT' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  CONTAINER_IMAGE="$(yq -r '.MATTER_SERVER.CONTAINER_IMAGE' "${CONFIG_YAML}")" 
  START_ON_BOOT="$(yq -r '.MATTER_SERVER.START_ON_BOOT' "${CONFIG_YAML}")" 
  RESTART_SERVICE_FOR_BACKUP="true"
}


function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo MATTER_SERVER_DATA_DIR=${MATTER_SERVER_DATA_DIR}
  echo MATTER_SERVER_HTTP_PORT=${MATTER_SERVER_HTTP_PORT}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo START_ON_BOOT=${START_ON_BOOT}
  echo RESTART_SERVICE_FOR_BACKUP=${RESTART_SERVICE_FOR_BACKUP}
}

function install() {
  CreatePodmanNetwork
  CreateQuadlet
  postInstall
  showStatus
}

main "$@"

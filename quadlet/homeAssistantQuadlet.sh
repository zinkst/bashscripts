#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function createDirs() {
  mkdir -p ${QUADLET_DIR}
  mkdir -p ${DATA_DIR}
  semanage fcontext -a -t svirt_sandbox_file_t "${DATA_DIR}(/.*)?"
  restorecon -Rv "${DATA_DIR}"
}

function CreateQuadlet() {
  cat <<EOF > ${QUADLET_DIR}/${SERVICE_NAME}.container 
[Unit]
Description=${SERVICE_NAME}

[Container]
Label=app=${SERVICE_NAME}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=${SERVICE_NAME}
Image=${HOME_ASSISTANT_CONTAINER_IMAGE}
Network=${NETWORK_NAME}
PublishPort=${HOME_ASSISTANT_HTTP_PORT}:${HOME_ASSISTANT_HTTP_PORT}
Volume=${DATA_DIR}:/config:Z
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam

[Install]
${START_ON_BOOT}
EOF
}

function setEnvVars() {
  setDefaultEnvVars
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  DATA_DIR="$(yq -r '.HOME_ASSISTANT.DATA_DIR' "${CONFIG_YAML}")"
  HOME_ASSISTANT_CONTAINER_IMAGE="$(yq -r '.HOME_ASSISTANT.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  HOME_ASSISTANT_HTTP_PORT="$(yq -r '.HOME_ASSISTANT.HTTP_PORT' "${CONFIG_YAML}")"
  SERVICE_NAME="home-assistant"
  START_ON_BOOT="$(yq -r '.HOME_ASSISTANT.START_ON_BOOT' "${CONFIG_YAML}")" 
}

function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo DATA_DIR=${DATA_DIR}
  echo HOME_ASSISTANT_CONTAINER_IMAGE=${HOME_ASSISTANT_CONTAINER_IMAGE}
  echo HOME_ASSISTANT_HTTP_PORT=${HOME_ASSISTANT_HTTP_PORT}
  echo SERVICE_NAME=${SERVICE_NAME}
  echo START_ON_BOOT=${START_ON_BOOT}
}

function install() {
  createDirs
  CreateQuadlet
  postInstall
  showStatus
}

main "$@"

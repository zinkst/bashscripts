#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function CreateQuadlet() {
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
Network=${NETWORK_NAME}
PublishPort=${NODE_EXPORTER_HTTP_PORT}:9100
AddCapability=CAP_AUDIT_WRITE

[Service]
Restart=on-failure

[Install]
${START_ON_BOOT}
EOF
}

function setEnvVars() {
  setDefaultEnvVars
  SERVICE_NAME="node-exporter"
  NODE_EXPORTER_HTTP_PORT="$(yq -r '.NODE_EXPORTER.HTTP_PORT' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  CONTAINER_IMAGE="$(yq -r '.NODE_EXPORTER.CONTAINER_IMAGE' "${CONFIG_YAML}")" 
  START_ON_BOOT="$(yq -r '.NODE_EXPORTER.START_ON_BOOT' "${CONFIG_YAML}")" 
}


function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo NODE_EXPORTER_HTTP_PORT=${NODE_EXPORTER_HTTP_PORT}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo START_ON_BOOT=${START_ON_BOOT}
}

function install() {
  CreatePodmanNetwork
  CreateQuadlet
  postInstall
  showStatus
}

main "$@"

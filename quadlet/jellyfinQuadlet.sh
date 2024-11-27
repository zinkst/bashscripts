#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function installPrereqs() {
  sudo setsebool -P container_use_dri_devices 1
}

function CreateQuadlet() {
  mkdir -p ${JF_DATA_DIR}
  mkdir -p ${JF_CONFIG_DIR}
  cat <<EOF > "${QUADLET_DIR}/${SERVICE_NAME}.container" 
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
AddDevice=/dev/dri/:/dev/dri/
PublishPort=${HTTP_PORT}:8096
PublishPort=${DLNA_PORT}:1900
Volume=${JF_DATA_DIR}:/config:Z
Volume=${JF_CONFIG_DIR}:/cache:Z
Volume=${VIDEOS_DIR}:/FamilienVideos:ro,Z
Volume=${PHOTOS_DIR}:/Photos:ro,Z
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
  SERVICE_NAME="jellyfin"
  OVERRIDE_NETWORK="$(yq -r '.JELLYFIN.NETWORK_NAME' "${CONFIG_YAML}")"
  if [ "${OVERRIDE_NETWORK}" != "null" ]; then
    NETWORK_NAME="${OVERRIDE_NETWORK}"
  fi       
  DATA_DIR="$(yq -r '.JELLYFIN.DATA_DIR' "${CONFIG_YAML}")"
  JF_DATA_DIR="${DATA_DIR}/data"
  JF_CONFIG_DIR="${DATA_DIR}/config"
  HTTP_PORT="$(yq -r '.JELLYFIN.HTTP_PORT' "${CONFIG_YAML}")"
  DLNA_PORT="$(yq -r '.JELLYFIN.DLNA_PORT' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  START_ON_BOOT="$(yq -r '.JELLYFIN.START_ON_BOOT' "${CONFIG_YAML}")" 
  CONTAINER_IMAGE="$(yq -r '.JELLYFIN.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  VIDEOS_DIR="$(yq -r '.JELLYFIN.VIDEOS_DIR' "${CONFIG_YAML}")"
  PHOTOS_DIR="$(yq -r '.JELLYFIN.PHOTOS_DIR' "${CONFIG_YAML}")"
}


function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo DATA_DIR=${DATA_DIR}
  echo HTTP_PORT=${HTTP_PORT}
  echo DLNA_PORT=${DLNA_PORT}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo START_ON_BOOT=${START_ON_BOOT}
  echo VIDEOS_DIR=${VIDEOS_DIR}
  echo PHOTOS_DIR=${PHOTOS_DIR}
}

function install() {
  installPrereqs
  CreatePodmanNetwork
  CreateQuadlet
  postInstall
  showStatus
}

main "$@"

#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function createDirs() {
  mkdir -p ${QUADLET_DIR}
  mkdir -p ${DATA_DIR}
  semanage fcontext -a -t svirt_sandbox_file_t "${DATA_DIR}(/.*)?"
  restorecon -Rv "${DATA_DIR}"
}

function createPrereqs() {
  printf "${VAULTWARDEN_ADMIN_TOKEN}" | podman secret create --replace vaultwarden-admin-token -
}

function CreateQuadletVaultwarden() {
  cat <<EOF > ${QUADLET_DIR}/${SERVICE_NAME}.container 
[Unit]
Description=${SERVICE_NAME}

[Container]
Label=app=${SERVICE_NAME}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=${SERVICE_NAME}
Image=${CONTAINER_IMAGE}
Network=${NETWORK_NAME}
PublishPort=${VAULTWARDEN_ROCKET_PORT}:${VAULTWARDEN_ROCKET_PORT}
Volume=${DATA_DIR}:/data:Z
Volume=/etc/localtime:/etc/localtime:ro
Environment=DOMAIN=https://${CADDY_PROXY_DOMAIN}:${VAULTWARDEN_HTTPS_PORT}
Environment=TZ=Europe/Amsterdam
Environment=ROCKET_PORT=${VAULTWARDEN_ROCKET_PORT}
Secret=vaultwarden-admin-token,type=env,target=ADMIN_TOKEN

[Install]
${START_ON_BOOT}
EOF
}


function remove() {
  ${SYSTEMCTL_CMD} disable --now ${SERVICE_NAME}.service
  rm "${QUADLET_DIR}/${SERVICE_NAME}.container"
  podman secret rm vaultwarden-admin-token
}

function setEnvVars() {
  setDefaultEnvVars
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  DATA_DIR="$(yq -r '.VAULTWARDEN.DATA_DIR' "${CONFIG_YAML}")"
  VAULTWARDEN_ADMIN_TOKEN="$(yq -r '.VAULTWARDEN.ADMIN_TOKEN' "${CONFIG_YAML}")"
  CONTAINER_IMAGE="$(yq -r '.VAULTWARDEN.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  VAULTWARDEN_ROCKET_PORT="$(yq -r '.VAULTWARDEN.ROCKET_PORT' "${CONFIG_YAML}")"
  VAULTWARDEN_HTTPS_PORT="$(yq -r '.VAULTWARDEN.HTTPS_PORT' "${CONFIG_YAML}")"
  CADDY_PROXY_DOMAIN="$(yq -r '.CADDY.PROXY_DOMAIN' "${CONFIG_YAML}")"
  SERVICE_NAME="vaultwarden"
  START_ON_BOOT="$(yq -r '.GRAFANA.START_ON_BOOT' "${CONFIG_YAML}")" 
  NUM_BACKUPS=7
}

function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo DATA_DIR=${DATA_DIR}
  echo VAULTWARDEN_ADMIN_TOKEN=${VAULTWARDEN_ADMIN_TOKEN}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo VAULTWARDEN_ROCKET_PORT=${VAULTWARDEN_ROCKET_PORT}
  echo VAULTWARDEN_HTTPS_PORT=${VAULTWARDEN_HTTPS_PORT}
  echo SERVICE_NAME=${SERVICE_NAME}
  echo CADDY_PROXY_DOMAIN=${CADDY_PROXY_DOMAIN}
  echo START_ON_BOOT=${START_ON_BOOT}
}

function install() {
  createDirs
  createPrereqs
  CreateQuadletVaultwarden
  postInstall
  showStatus
}

main "$@"

#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function CreateQuadlet() {
  mkdir -p ${GRAFANA_DATA_DIR}
  # chmod 777 -R ${GRAFANA_DATA_DIR}
  # chown -R 65534:65534 ${GRAFANA_DATA_DIR}
  # chcon -t container_file_t ${GRAFANA_DATA_DIR}
  mkdir -p ${GRAFANA_ETC_DIR}
  if [ ! -f ${GRAFANA_ETC_DIR}/grafana.ini ]; then
    DO_CONFIG="true"
    wget -O ${GRAFANA_ETC_DIR}/grafana.ini https://github.com/grafana/grafana/raw/refs/heads/main/conf/sample.ini
  fi
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
PublishPort=${GRAFANA_HTTP_PORT}:3000
Volume=${GRAFANA_DATA_DIR}:/var/lib/grafana:Z
Volume=${GRAFANA_ETC_DIR}/grafana.ini:/etc/grafana/grafana.ini:Z
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam

[Service]
Restart=on-failure

[Install]
${START_ON_BOOT}
EOF
}

function configure() {
  podman exec -ti grafana grafana-cli admin reset-admin-password "${ADMIN_PWD}"
}

function setEnvVars() {
  setDefaultEnvVars
  SERVICE_NAME="grafana"
  DATA_DIR="$(yq -r '.GRAFANA.DATA_DIR' "${CONFIG_YAML}")"
  GRAFANA_DATA_DIR="${DATA_DIR}/data"
  GRAFANA_ETC_DIR="${DATA_DIR}/etc"
  SERVER_IP=$(hostname -I | awk '{print $1}')
  GRAFANA_HTTP_PORT="$(yq -r '.GRAFANA.HTTP_PORT' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  CONTAINER_IMAGE="$(yq -r '.GRAFANA.CONTAINER_IMAGE' "${CONFIG_YAML}")" 
  START_ON_BOOT="$(yq -r '.GRAFANA.START_ON_BOOT' "${CONFIG_YAML}")" 
  ADMIN_PWD="$(yq -r '.GRAFANA.ADMIN_PWD' "${CONFIG_YAML}")"
  DO_CONFIG=${DO_CONFIG:-"false"}
}


function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo GRAFANA_DATA_DIR=${GRAFANA_DATA_DIR}
  echo GRAFANA_ETC_DIR=${GRAFANA_ETC_DIR}
  echo GRAFANA_HTTP_PORT=${GRAFANA_HTTP_PORT}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo START_ON_BOOT=${START_ON_BOOT}
  echo ADMIN_PWD=${ADMIN_PWD}
  echo DO_CONFIG=${DO_CONFIG}
}

function install() {
  CreatePodmanNetwork
  CreateQuadlet
  postInstall
  if [ "${DO_CONFIG}" == "true" ]; then
    configure
  fi  
  showStatus
}

main "$@"

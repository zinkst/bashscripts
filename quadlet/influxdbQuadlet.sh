#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function CreateQuadlet() {
  mkdir -p ${DATA_DIR}/data
  mkdir -p ${DATA_DIR}/etc
  printf "${ADMIN_TOKEN}" | podman secret create --replace influxdb-admin-token -
  printf "${ADMIN_PASSWORD}" | podman secret create --replace influxdb-init-password -

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
PublishPort=${HTTP_PORT}:8086
Volume=${INFLUXDB_DATA_DIR}:/var/lib/influxdb2:Z
Volume=${INFLUXDB_ETC_DIR}:/etc/influxdb2:Z
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam
Environment=DOCKER_INFLUXDB_INIT_MODE=setup
Environment=DOCKER_INFLUXDB_INIT_USERNAME=influxadm
Environment=DOCKER_INFLUXDB_INIT_ORG=init-org
Environment=DOCKER_INFLUXDB_INIT_BUCKET=init-bucket
Secret=influxdb-admin-token,type=env,target=DOCKER_INFLUXDB_INIT_ADMIN_TOKEN
Secret=influxdb-init-password,type=env,target=DOCKER_INFLUXDB_INIT_PASSWORD

[Install]
${START_ON_BOOT}
EOF
}

# docker run -d -p 8086:8086 \
#     -v "$PWD/data:/var/lib/influxdb2" \
#     -v "$PWD/config:/etc/influxdb2" \
#     -e DOCKER_INFLUXDB_INIT_MODE=setup \
#     -e DOCKER_INFLUXDB_INIT_USERNAME=my-user \
#     -e DOCKER_INFLUXDB_INIT_PASSWORD=my-password \
#     -e DOCKER_INFLUXDB_INIT_ORG=my-org \
#     -e DOCKER_INFLUXDB_INIT_BUCKET=my-bucket \
#     -e DOCKER_INFLUXDB_INIT_RETENTION=1w \
#     -e DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=my-super-secret-auth-token \
#     influxdb:2


function setEnvVars() {
  setDefaultEnvVars
  SERVICE_NAME="influxdb"
  DATA_DIR="$(yq -r '.INFLUXDB.DATA_DIR' "${CONFIG_YAML}")"
  INFLUXDB_DATA_DIR="${DATA_DIR}/data"
  INFLUXDB_ETC_DIR="${DATA_DIR}/etc"
  HTTP_PORT="$(yq -r '.INFLUXDB.HTTP_PORT' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  START_ON_BOOT="$(yq -r '.INFLUXDB.START_ON_BOOT' "${CONFIG_YAML}")" 
  CONTAINER_IMAGE="$(yq -r '.INFLUXDB.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  ADMIN_PASSWORD="$(yq -r '.INFLUXDB.ADMIN_PASSWORD' "${CONFIG_YAML}")"
  ADMIN_TOKEN="$(yq -r '.INFLUXDB.ADMIN_TOKEN' "${CONFIG_YAML}")"
}

function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo DATA_DIR=${DATA_DIR}
  echo HTTP_PORT=${HTTP_PORT}
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

#!/bin/bash

# inspired by https://github.com/immich-app/immich/discussions/1912
# and https://github.com/tbelway/immich-podman-quadlets/blob/main/docs/install/podman-quadlet.md
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function createDirs() {
  mkdir -p ${DATA_DIR}
  mkdir -p ${DATA_DIR}/{postgres,immich-server,redis,ml-model}
  mkdir -p ${QUADLET_DIR}
}

function createPrereqs() {
  printf "${PG_PASSWORD}" | podman secret create --replace immich-pg-password -
}

function CreateQuadletImmichPod() {
  cat <<EOF > ${QUADLET_DIR}/immich.pod
[Unit]
Description=Immich Pod

[Pod]
PodName=immich.pod
Network=${NETWORK_NAME}
PublishPort=${HTTP_PORT}:${HTTP_PORT}
EOF
}

function CreateQuadletImmichPostgres() {
POSTGRES_USER=postgres
POSTGRES_DB=immich
  cat <<EOF > ${QUADLET_DIR}/immich-postgres.container
[Unit]
Description=Immich Database
Requires=immich-redis.service

[Container]
ContainerName=immich-postgres
Network=${NETWORK_NAME}
# Pod=immich.pod
Image=${PG_CONTAINER_IMAGE}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
Volume=${DATA_DIR}/postgres:/var/lib/postgresql/data
Secret=immich-pg-password,type=env,target=POSTGRES_PASSWORD
Environment=POSTGRES_USER=${POSTGRES_USER}
Environment=POSTGRES_DB=${POSTGRES_DB}
Environment=POSTGRES_INITDB_ARGS=--data-checksums
Environment=DB_STORAGE_TYPE=HDD

[Service]
Restart=always
TimeoutStartSec=90

[Install]
${START_ON_BOOT}
EOF
}  

function CreateQuadletImmichRedis() {
  cat <<EOF > ${QUADLET_DIR}/immich-redis.container
[Container]
ContainerName=immich-redis
Network=${NETWORK_NAME}
# Pod=immich.pod
Image=${REDIS_IMAGE}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
HealthCmd=redis-cli ping || exit 1
Volume=${DATA_DIR}/redis:/data

[Service]
Restart=always
TimeoutStartSec=90

[Install]
${START_ON_BOOT}
EOF
}

function CreateQuadletImmichMachineLearning() {
  cat <<EOF > ${QUADLET_DIR}/immich-machine-learning.container
[Unit]
Description=Immich Machine Learning
Requires=immich-redis.service immich-postgres.service

[Container]
ContainerName=immich-machine-learning
Network=${NETWORK_NAME}
# Pod=immich.pod
Image=${MACHINE_LEARNING_IMAGE}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
Volume=${DATA_DIR}/ml-model:/cache

[Service]
Restart=always
TimeoutStartSec=90

[Install]
${START_ON_BOOT}
EOF
}

function CreateQuadletImmichServer() {
  cat <<EOF > ${QUADLET_DIR}/immich-server.container
[Unit]
Description=Immich Server
Requires=immich-redis.service immich-postgres.service

[Container]
ContainerName=immich-server
Network=${NETWORK_NAME}
# Pod=immich.pod
Image=${CONTAINER_IMAGE}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
Volume=${DATA_DIR}/immich-server:/usr/src/app/upload
Volume=${EXTERNAL_LIBRARY_DIR}:/external_library:ro
Volume=/etc/localtime:/etc/localtime:ro
HealthCmd=["/bin/bash", "immich-healthcheck"]
Secret=immich-pg-password,type=env,target=DB_PASSWORD
Environment=DB_USERNAME=postgres
Environment=DB_DATABASE_NAME=immich
Environment=DB_HOSTNAME=immich-postgres
Environment=REDIS_HOSTNAME=immich-redis
Environment=IMMICH_PORT=${HTTP_PORT}
PublishPort=${HTTP_PORT}:${HTTP_PORT}
# Environment=IMMICH_LOG_LEVEL=debug

[Service]
Restart=always
TimeoutStartSec=90

[Install]
${START_ON_BOOT}

EOF
}



function setEnvVars() {
  setDefaultEnvVars
  SERVICE_NAME="immich"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  START_ON_BOOT="$(yq -r '.IMMICH.START_ON_BOOT' "${CONFIG_YAML}")" 
  DATA_DIR="$(yq -r '.IMMICH.DATA_DIR' "${CONFIG_YAML}")"
  HTTP_PORT="$(yq -r '.IMMICH.HTTP_PORT' "${CONFIG_YAML}")"
  PG_PASSWORD="$(yq -r '.IMMICH.PG_PASSWORD' "${CONFIG_YAML}")"
  PG_CONTAINER_IMAGE="$(yq -r '.IMMICH.PG_CONTAINER_IMAGE' "${CONFIG_YAML}")"
  REDIS_IMAGE="$(yq -r '.IMMICH.REDIS_IMAGE' "${CONFIG_YAML}")"
  MACHINE_LEARNING_IMAGE="$(yq -r '.IMMICH.MACHINE_LEARNING_IMAGE' "${CONFIG_YAML}")"
  CONTAINER_IMAGE="$(yq -r '.IMMICH.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  EXTERNAL_LIBRARY_DIR="$(yq -r '.IMMICH.EXTERNAL_LIBRARY_DIR' "${CONFIG_YAML}")"
  QUADLETS=(
    immich-postgres.container
    immich-redis.container
    immich-machine-learning.container
    immich-server.container
  )
  SERVICES=(
    immich-redis
    immich-postgres
    immich-machine-learning
    immich-server
  )
}

function printEnvVars() {
  printDefaultEnvVars
  echo DATA_DIR=${DATA_DIR}
  echo EXTERNAL_LIBRARY_DIR=${EXTERNAL_LIBRARY_DIR}
  echo HTTP_PORT=${HTTP_PORT}
  echo START_ON_BOOT=${START_ON_BOOT}
  echo PG_CONTAINER_IMAGE=${PG_CONTAINER_IMAGE}
  echo REDIS_IMAGE=${REDIS_IMAGE}
  echo MACHINE_LEARNING_IMAGE=${MACHINE_LEARNING_IMAGE}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo TEST_MODE=${TEST_MODE}
}


function install() {
  createDirs
  createPrereqs
  CreatePodmanNetwork
  # CreateQuadletImmichPod
  CreateQuadletImmichPostgres
  CreateQuadletImmichRedis
  CreateQuadletImmichMachineLearning
  CreateQuadletImmichServer
  postInstall
  showStatus
}

function postInstall() { 
  ${SYSTEMCTL_CMD} daemon-reload
  # ${SYSTEMCTL_CMD} start immich-pod.service
  for  i in ${!SERVICES[@]}; do
     ${SYSTEMCTL_CMD} start ${SERVICES[$i]}
  done 
  for  i in ${!SERVICES[@]}; do
     ${SYSTEMCTL_CMD} status --no-pager ${SERVICES[$i]}
  done 
}

function remove() {
  for  i in ${!SERVICES[@]}; do
    cmd="${SYSTEMCTL_CMD} stop ${SERVICES[$i]}"
    run-cmd "${cmd}"
  done 
  for  i in ${!QUADLETS[@]}; do
    echo "removing quadlet ${QUADLETS[$i]}"
    cmd="rm ${QUADLET_DIR}/${QUADLETS[$i]}"
    echo "${cmd}"
    eval "${cmd}"
  done
}

function update() {
  for  i in ${!SERVICES[@]}; do
    cmd="${SYSTEMCTL_CMD} stop ${SERVICES[$i]}"
    run-cmd "${cmd}"
  done 
  updateComponent "${CONTAINER_IMAGE}" "immich-server" "false"
  updateComponent "${REDIS_IMAGE}" "immich-redis" "false"
  updateComponent "${MACHINE_LEARNING_IMAGE}" "immich-machine-learning" "false"
  updateComponent "${PG_CONTAINER_IMAGE}" "immich-postgres" "false"
  cmd="${SYSTEMCTL_CMD} daemon-reload"
  run-cmd "${cmd}"
  for  i in ${!SERVICES[@]}; do
    cmd="${SYSTEMCTL_CMD} start ${SERVICES[$i]}"
    run-cmd "${cmd}"
  done 
  showStatus
}


# main start here
main "$@"
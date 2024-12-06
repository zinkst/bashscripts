#!/bin/bash

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
Image=${CONTAINER_IMAGE}
Network=${NETWORK_NAME}
PublishPort=${HOME_ASSISTANT_HTTP_PORT}:${HOME_ASSISTANT_HTTP_PORT}
Volume=${DATA_DIR}:/config:Z
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam

[Service]
Restart=on-failure

[Install]
${START_ON_BOOT}
EOF
}

function backup () {
  printEnvVars
  export BACKUP_DIR=/links/sysbkp/${SERVICE_NAME}
  export NUM_BACKUPS=${NUM_BACKUPS:-3}
  source /links/bin/lib/dbBackupFunctions.sh
  initDirWithBackupFiles ${SERVICE_NAME}_internalBackup.tar
  rotateFiles ${SERVICE_NAME}_internalBackup.tar
  echo "[INFO] creating new backup using hass-cli"
  CMD="hass-cli service call backup.create"
  run-cmd "${CMD}"
  echo "[INFO] moving internal backup of ${SERVICE_NAME} to ${BACKUP_DIR}"
  CMD="mv $DATA_DIR/backups/*.tar ${BACKUP_DIR}/${SERVICE_NAME}_internalBackup.tar"
  run-cmd "${CMD}"
  echo "[INFO] creating backup of ${DATA_DIR}"
  initDirWithBackupFiles ${SERVICE_NAME}.tgz
  rotateFiles ${SERVICE_NAME}.tgz
  CMD="tar -czf  ${BACKUP_DIR}/${SERVICE_NAME}.tgz --directory \"${DATA_DIR}/\" . || true"
  run-cmd "${CMD}"
  echo "[INFO] finished Backup of ${SERVICE_NAME}"
  createBackupService
  createBackupTimer
}	

function setEnvVars() {
  setDefaultEnvVars
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  DATA_DIR="$(yq -r '.HOME_ASSISTANT.DATA_DIR' "${CONFIG_YAML}")"
  CONTAINER_IMAGE="$(yq -r '.HOME_ASSISTANT.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  HOME_ASSISTANT_HTTP_PORT="$(yq -r '.HOME_ASSISTANT.HTTP_PORT' "${CONFIG_YAML}")"
  SERVICE_NAME="home-assistant"
  START_ON_BOOT="$(yq -r '.HOME_ASSISTANT.START_ON_BOOT' "${CONFIG_YAML}")"
  NUM_BACKUPS=7
  INSTALLED_VERSION=$(podman image inspect ${CONTAINER_IMAGE} | jq -r .[0].Config.Labels.\"io.hass.version\")
  RESTART_SERVICE_FOR_BACKUP="false"
  export HASS_SERVER="$(yq -r '.HOME_ASSISTANT.HASS_SERVER' "${CONFIG_YAML}")"
  export HASS_TOKEN="$(yq -r '.HOME_ASSISTANT.HASS_TOKEN' "${CONFIG_YAML}")"
}

function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo DATA_DIR=${DATA_DIR}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo HOME_ASSISTANT_HTTP_PORT=${HOME_ASSISTANT_HTTP_PORT}
  echo SERVICE_NAME=${SERVICE_NAME}
  echo START_ON_BOOT=${START_ON_BOOT}
  echo "INSTALLED_VERSION=${INSTALLED_VERSION}"
  echo RESTART_SERVICE_FOR_BACKUP=${RESTART_SERVICE_FOR_BACKUP}
  echo "HASS_SERVER=${HASS_SERVER}"
}

function install() {
  createDirs
  CreateQuadlet
  postInstall
  showStatus
}

main "$@"

#!/bin/bash


function run-cmd () {
  if [ ${TEST_MODE} == "false" ]; then
		eval "${1}"
	else
	  echo "${1}"
	fi	
}

function CreatePodmanNetwork() {
  podman network create ${NETWORK_NAME} --ignore
}

function postInstall() {
  ${SYSTEMCTL_CMD} daemon-reload
  ${SYSTEMCTL_CMD} start ${SERVICE_NAME}.service
}

function remove() {
  ${SYSTEMCTL_CMD} disable ${SERVICE_NAME}.service --now
  rm ${QUADLET_DIR}/${SERVICE_NAME}.container
}

function showStatus() {
  SERVICES=(
    ${SERVICE_NAME}
  )
  for  i in ${!SERVICES[@]}; do
        echo "###################################################"
        echo "Show status for service ${SERVICES[$i]}"
        ${SYSTEMCTL_CMD} --no-pager is-active  ${SERVICES[$i]}
  done
}

function update() {
  echo CONTANER_IMAGE="${CONTAINER_IMAGE}"
  echo INSTALLED_VERSION="${INSTALLED_VERSION}"
  echo "[INFO] pulling ${CONTAINER_IMAGE}"
  cmd="podman pull ${CONTAINER_IMAGE}"
  run-cmd "${cmd}"
  echo "[INFO] labels of new image"
  cmd="podman inspect ${CONTAINER_IMAGE} | jq -r \".[].Labels\""
  run-cmd "${cmd}"
  eval "${cmd}"
  # PULLED_VERSION=$(podman image inspect ${IMAGE} | jq -r .[0].Config.Labels.\"org.opencontainers.image.version\")
  # echo PULLED_VERSION=${PULLED_VERSION} 
  # # podman auto-update --dry-run --format "{{.Image}} {{.Updated}}"
  # podman auto-update will update all registered containers so will not use it
  echo "[INFO] stopping ${SERVICE_NAME}"
  cmd="systemctl stop ${SERVICE_NAME}"
  run-cmd "${cmd}"
  echo "[INFO] starting ${SERVICE_NAME}"
  cmd="systemctl start ${SERVICE_NAME}"
  run-cmd "${cmd}"
}

function usage() {
  echo "##################"
  echo "Parameters available"
  echo "-c <path-to-config-file> (required) "
  echo "-i to install ${SERVICE_NAME}"
  echo "-u to update ${SERVICE_NAME}"
  echo "-r to remove/uninstall ${SERVICE_NAME}"
  echo "-b to backup ${SERVICE_NAME}"
  echo "-s to show status of ${SERVICE_NAME} "
}

function setDefaultEnvVars() {
  if [[ $(id -u) -eq 0 ]] ; then 
    echo "running as USER root" 
    export QUADLET_DIR=/etc/containers/systemd
    export SYSTEMD_UNIT_DIR=/etc/systemd/system
    export SYSTEMCTL_CMD="systemctl"
  else  
    echo "running as USER ${USER}" 
    export QUADLET_DIR=${HOME}/.config/containers/systemd
    export SYSTEMD_UNIT_DIR=${HOME}/.config/systemd/user
    export SYSTEMCTL_CMD="systemctl --user"
  fi
  export NETWORK_NAME="$(yq -r '.HOST.PODMAN_NETWORK_NAME' "${CONFIG_YAML}")"
  export IS_DEVELOPMENT_SYSTEM="$(yq -r '.HOST.IS_DEVELOPMENT_SYSTEM' "${CONFIG_YAML}")"
  export SERVER_NAME=$(hostname -s)
  export INSTALLED_VERSION="not set" # overwrite in implementation
}

function printDefaultEnvVars() {
  echo CONFIG_YAML=${CONFIG_YAML}
  echo QUADLET_DIR=${QUADLET_DIR}
  echo SYSTEMD_UNIT_DIR=${SYSTEMD_UNIT_DIR}
  echo SYSTEMCTL_CMD=${SYSTEMCTL_CMD}
  echo NETWORK_NAME=${NETWORK_NAME}
  echo IS_DEVELOPMENT_SYSTEM=${IS_DEVELOPMENT_SYSTEM}
  echo SERVER_NAME=${SERVER_NAME}
}

function backup () {
  export BACKUP_DIR=/links/sysbkp/${SERVICE_NAME}
  export NUM_BACKUPS=${NUM_BACKUPS:-3}
  source /links/bin/lib/dbBackupFunctions.sh
  initDirWithBackupFiles ${SERVICE_NAME}.tgz
  rotateFiles ${SERVICE_NAME}.tgz
  START_SERVICE_AFTER_BACKUP="false"
  if [ "$(${SYSTEMCTL_CMD} is-active ${SERVICE_NAME}.service)" == "active" ]; then
    START_SERVICE_AFTER_BACKUP="true"
    CMD="${SYSTEMCTL_CMD} stop ${SERVICE_NAME}" 
    run-cmd "${CMD}"
    echo "give 60 seconds to bring down ${SERVICE_NAME} completely"
    CMD="sleep 60"
    run-cmd "${CMD}"
  fi
  echo "creating backup of ${SERVICE_NAME}"
  CMD="tar -czf  ${BACKUP_DIR}/${SERVICE_NAME}.tgz --directory \"${DATA_DIR}/\" ."
  run-cmd "${CMD}"
  if [ "${START_SERVICE_AFTER_BACKUP}" == "true" ]; then
    CMD="${SYSTEMCTL_CMD} start ${SERVICE_NAME}" 
    run-cmd "${CMD}"
  fi
  echo "finished Backup of ${SERVICE_NAME}"
  createBackupService
  createBackupTimer
}	

function createBackupService() {
  if [ -f "/links${SYSTEMD_UNIT_DIR}/backup-${SERVICE_NAME}.service" ]; then
    echo "systemd service ${SERVICE_NAME}.service already exists"
    return
  fi   
	
  cat << EOF > /links${SYSTEMD_UNIT_DIR}/backup-${SERVICE_NAME}.service
[Unit]
Description=Backup ${SERVICE_NAME} data folder

[Service]
Type=simple
Environment="NUM_BACKUPS=${NUM_BACKUPS}"
ExecStart=/links/bin/quadlet/$(basename ${0}) -c /links/etc/my-etc/quadlet/config-$(hostname -s).yml -b
EOF

  if [ "${IS_DEVELOPMENT_SYSTEM}" == "false" ]; then
    if [ ! -f "${SYSTEMD_UNIT_DIR}/backup-${SERVICE_NAME}.service" ]; then
      echo "creating symlinks for backup services of ${SERVICE_NAME}"
      ln -sf /links${SYSTEMD_UNIT_DIR}/backup-${SERVICE_NAME}.service ${SYSTEMD_UNIT_DIR}/
    fi  
  fi
}

function createBackupTimer() {
  if [ -f "/links${SYSTEMD_UNIT_DIR}/backup-${SERVICE_NAME}.timer" ]; then
    echo "systemd timer ${SERVICE_NAME}.timer already exists"
    return
  fi	
	
  cat << EOF > /links${SYSTEMD_UNIT_DIR}/backup-${SERVICE_NAME}.timer
[Unit]
Description=Timer for Backup ${SERVICE_NAME} data folder

[Timer]
OnCalendar=*-*-* 0$(shuf -i 1-4 -n 1):$(shuf -i 0-5 -n 1)0:00
Persistent=True
Unit=backup-${SERVICE_NAME}.service

[Install]
WantedBy=basic.target
EOF

  if [ "${IS_DEVELOPMENT_SYSTEM}" == "false" ]; then
    if [ ! -f "${SYSTEMD_UNIT_DIR}/backup-${SERVICE_NAME}.timer" ]; then
      echo "creating symlinks for backup services of ${SERVICE_NAME}"
      ln -sf /links${SYSTEMD_UNIT_DIR}/backup-${SERVICE_NAME}.timer ${SYSTEMD_UNIT_DIR}/
    fi
    ${SYSTEMCTL_CMD} daemon-reload  
    ${SYSTEMCTL_CMD} enable backup-${SERVICE_NAME}.timer --now
  fi
}

function checkpCLIParams() {
  TEST_MODE="false"
  DEFAULT_CONFIG_YAML="/links/etc/my-etc/quadlet/config-$(hostname -s).yml"
  while getopts "iubrstc:" OPTNAME; do
    case "${OPTNAME}" in
      i )
        echo "Runmode Option ${OPTNAME} is specified"
        RUN_MODE="INSTALL"
        ;;
      r )
        echo "Runmode Option ${OPTNAME} is specified"
        RUN_MODE="REMOVE"
        ;;
      s )
        echo "Runmode Option ${OPTNAME} is specified"
        RUN_MODE="STATUS"
        ;;
      u )
        echo "Runmode Option ${OPTNAME} is specified"
        RUN_MODE="UPDATE"
        ;;
      b )
        echo "Runmode Option ${OPTNAME} is specified"
        RUN_MODE="BACKUP"
        ;;
      t )
        echo "Testmode ${OPTNAME} is specified"
        TEST_MODE="true"
        ;;
      c )
        echo "config file used is \"${OPTARG}\" is specified"
        CONFIG_YAML="${OPTARG}"
        ;;
      * )
        echo "unknown parameter specified"
        usage
        exit 1
        ;;
    esac
  done
  if [ $OPTIND -eq 1 ]; then 
    echo "[ERROR] No options were passed"; 
    usage
    exit 1
  fi
  if [ -z "${CONFIG_YAML+x}" ]; then
    echo "[WARN] config File not specified trying default config path"
    CONFIG_YAML="${DEFAULT_CONFIG_YAML}"
  fi
  if [ ! -f "${CONFIG_YAML}" ]; then 
    echo "[ERROR] Config file does not exist Please specify an existing config file witch -c"; 
    usage
    exit 1
  fi  
  if [ -z "${RUN_MODE+x}" ]; then
     echo "[ERROR] No Runmode mode specified specify either -c or -u"
     usage
     exit 1
  fi   
}

# main start here
function main() {
  checkpCLIParams "$@"
  setEnvVars
  printEnvVars
  case "${RUN_MODE}" in 
    "INSTALL" )
      install ;;
    "REMOVE")
      remove ;;
    "STATUS")
      showStatus ;;
    "UPDATE")
      update ;;
    "BACKUP")
      backup ;;
    * )
      echo "Invalid Installation mode specified specifed us either -c or -u parameter"
      usage; 
      exit 1
      ;;
  esac    
}

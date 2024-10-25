#!/bin/bash

function CreatePodmanNetwork() {
  podman network create ${NETWORK_NAME} --ignore
}

function postInstall() {
  ${SYSTEMCTL_CMD} daemon-reload
  ${SYSTEMCTL_CMD} start ${SERVICE_NAME}.service
}

function remove() {
  ${SYSTEMCTL_CMD} stop ${SERVICE_NAME}.service
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
  echo "not implemented"
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
  SERVICE_NAME="node-exporter"
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
}

function printDefaultEnvVars() {
  echo CONFIG_YAML=${CONFIG_YAML}
  echo QUADLET_DIR=${QUADLET_DIR}
  echo SYSTEMD_UNIT_DIR=${SYSTEMD_UNIT_DIR}
  echo SYSTEMCTL_CMD=${SYSTEMCTL_CMD}
  echo NETWORK_NAME=${NETWORK_NAME}
  echo SERVICE_NAME=${SERVICE_NAME}
}

function backup () {
  export BACKUP_DIR=/links/sysbkp/${SERVICE_NAME}
  export NUM_BACKUPS=${NUM_BACKUPS:-3}
  source /links/bin/lib/dbBackupFunctions.sh
  initDirWithBackupFiles ${SERVICE_NAME}.tgz
  rotateFiles ${SERVICE_NAME}.tgz
  CMD="systemctl stop ${SERVICE_NAME}" 
  run-cmd "${CMD}"
  echo "give 60 seconds to bring down ${SERVICE_NAME} completely"
  CMD="sleep 60"
  run-cmd "${CMD}"
  echo "creating backup of ${SERVICE_NAME}"
  CMD="tar -czf  ${BACKUP_DIR}/${SERVICE_NAME}.tgz --directory \"${DATA_DIR}/\" ."
  run-cmd "${CMD}"
  CMD="systemctl start ${SERVICE_NAME}" 
  run-cmd "${CMD}"
  echo "finished Backup of ${SERVICE_NAME}"
}	


function checkpCLIParams() {
  TEST_MODE="false"
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
    echo "No options were passed"; 
    usage
    exit 1
  fi
  if [ -z "${CONFIG_YAML+x}" ]  || [ ! -f "${CONFIG_YAML}" ]; then 
    echo "Config file does not exist Please specify an existing config file witch -c"; 
    usage
  fi
  if [ -z "${RUN_MODE+x}" ]; then
     echo "No Runmode mode specified specify either -c or -u"
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

#!/bin/bash
export SERVICE_NAME="home-assistant"
export NUM_BACKUPS=${NUM_BACKUPS:-3}
export BACKUP_DIR=/links/sysbkp/${SERVICE_NAME}
source /links/bin/lib/dbBackupFunctions.sh


function backup () {
  CMD="systemctl stop ${SERVICE_NAME}" 
  run-cmd "${CMD}"
  echo "give 60 seconds to bring down ${SERVICE_NAME} completely"
  CMD="sleep 60"
  run-cmd "${CMD}"
  echo "creating backup of ${SERVICE_NAME}"
  CMD="tar -czf  ${BACKUP_DIR}/${SERVICE_NAME}.tgz --directory ${HOME_ASSISTANT_DATA_DIR}/ ."
  run-cmd "${CMD}"
  CMD="systemctl start ${SERVICE_NAME}" 
  run-cmd "${CMD}"
}	


function setEnvVars() {
  HOME_ASSISTANT_DATA_DIR="$(yq -r '.HOME_ASSISTANT.DATA_DIR' "${CONFIG_YAML}")"
}

function printEnvVars() {
  echo CONFIG_YAML="${CONFIG_YAML}"
  echo HOME_ASSISTANT_DATA_DIR=${HOME_ASSISTANT_DATA_DIR}
}


function usage() {
  echo "##################"
  echo "Parameters available"
  echo "-c <path-to-config-file> (required) "
  echo "-t testMode"
}


#main
TEST_MODE="false"
while getopts "tc:" Option
do
    case $Option in
		t ) TEST_MODE="true";;
        c )
            echo "config file used is ${OPTARG} is specified"
            CONFIG_YAML="${OPTARG}";;
    esac
done

if [ -z "${CONFIG_YAML+x}" ]  || [ ! -f "${CONFIG_YAML}" ]; then 
   echo "Config file does not exist Please specify an existing config file witch -c"; 
   usage
fi
  
if [[ $(id -u) -ne 0 ]] ; then
    echo "Please run as root user"
    exit 1
fi

setEnvVars
printEnvVars
# createBackupSystemdService
# createBackupSystemdTimer
initDirWithBackupFiles ${SERVICE_NAME}.tgz
rotateFiles ${SERVICE_NAME}.tgz
backup  
ls -lh ${BACKUP_DIR}


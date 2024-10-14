#!/bin/bash
export SERVICE_NAME="nextcloud-quadlet"
export NUM_BACKUPS=${NUM_BACKUPS:-3}
export BACKUP_DIR=/links/sysbkp/nextcloud-quadlet
source /links/bin/lib/dbBackupFunctions.sh


function backupNextcloud () {
   CMD="podman exec -it -u www-data nextcloud-app php occ maintenance:mode --on" 
   run-cmd "${CMD}"
   echo "creating backup of nextcoud html "
   CMD="tar -czf  ${BACKUP_DIR}/nextcloud_html.tgz --directory ${NEXTCLOUD_ROOT_DIR}/html ."
   run-cmd "${CMD}"
   echo "creating mariadbdump backup of nextcloud db "
   CMD="podman exec -it nextcloud-db mariadb-dump -u ${MARIADB_USER} -p${MARIADB_USER_PASSWORD} ${MARIADB_DATABASE_NAME} | gzip -9 > ${BACKUP_DIR}/mariadb_dump.sql.gz"
   run-cmd "${CMD}"
   echo "creating backup of nextcloud db data volume"
   CMD="tar -czf  ${BACKUP_DIR}/nextcloud_db.tgz --directory ${NEXTCLOUD_ROOT_DIR}/db ."
   run-cmd "${CMD}"
   CMD="podman exec -it -u www-data nextcloud-app php occ maintenance:mode --off" 
   run-cmd "${CMD}"
}	

function setEnvVars() {
  NEXTCLOUD_ROOT_DIR=$(yq -r '.NEXTCLOUD.ROOT_DIR' "${CONFIG_YAML}")
  MARIADB_DATABASE_NAME=$(yq -r '.MARIADB.DATABASE_NAME' "${CONFIG_YAML}")
  MARIADB_USER=$(yq -r '.MARIADB.USER' "${CONFIG_YAML}")
  MARIADB_USER_PASSWORD=$(yq -r '.MARIADB.USER_PASSWORD' "${CONFIG_YAML}")
}

function printEnvVars() {
  echo CONFIG_YAML=${CONFIG_YAML}
  echo NEXTCLOUD_ROOT_DIR=${NEXTCLOUD_ROOT_DIR}
  echo MARIADB_DATABASE_NAME=${MARIADB_DATABASE_NAME}
  echo MARIADB_USER=${MARIADB_USER}
  echo MARIADB_USER_PASSWORD=${MARIADB_USER_PASSWORD}
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
# initDirWithBackupFiles nextcloud_html.tgz
# initDirWithBackupFiles nextcloud_db.tgz
# initDirWithBackupFiles mariadb_dump.sql.gz
rotateFiles nextcloud_html.tgz
rotateFiles nextcloud_db.tgz
rotateFiles mariadb_dump.sql.gz
backupNextcloud  
ls -l ${BACKUP_DIR}


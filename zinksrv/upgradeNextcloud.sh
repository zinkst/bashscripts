#!/bin/bash
source /links/bin/zinksrv/dbBackupFunctions.sh

export CLOUD_NAME="nextcloud"
export OLD_CLOUD_VER="22.2.2"
export NEW_CLOUD_VER="23.0.3"
export CLOUD_ROOT_DIR="/links/zinksrv/srv"
export NEW_CLOUD_DIR="${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}"
export OLD_CLOUD_DIR="${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${OLD_CLOUD_VER}"

function stopServices () {
	cmd="systemctl stop php-fpm && 	systemctl stop nginx &&	systemctl stop mariadb"
  run-cmd "${cmd}"
}

function startServices () {
	cmd="systemctl start mariadb && 	systemctl start nginx && 	systemctl start php-fpm"
  run-cmd "${cmd}"
}
	
function prepareNewNextcloud () {
  if ! [ -f  ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}.zip ]; 
  then 
    cmd="wget https://download.nextcloud.com/server/releases/nextcloud-${NEW_CLOUD_VER}.zip -O ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}.zip"
    run-cmd "${cmd}"
  fi  
  if [ -d ${NEW_CLOUD_DIR}/config ]; 
  then
    echo "${NEW_CLOUD_DIR} already exists please check versions" 
    exit -1 
  else
    cmd="rm ${CLOUD_ROOT_DIR}/${CLOUD_NAME}"
    run-cmd "${cmd}"
    cmd="unzip ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}.zip -d ${CLOUD_ROOT_DIR}/"
    run-cmd "${cmd}"
    cmd="mv ${CLOUD_ROOT_DIR}/${CLOUD_NAME} ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}"
    run-cmd "${cmd}"
    cmd="ln -sf ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER} ${CLOUD_ROOT_DIR}/${CLOUD_NAME}"
    run-cmd "${cmd}"
    cmd="chown apache:apache ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}/config"
    run-cmd "${cmd}"
    cmd="cp -prv ${OLD_CLOUD_DIR}/config/ca-bundle.crt ${OLD_CLOUD_DIR}/config/config.php ${NEW_CLOUD_DIR}/config/"
    run-cmd "${cmd}"
    ls -l ${CLOUD_ROOT_DIR}
  fi	
		
}

function startUpgrade() {
  cmd="sudo -u apache php ${NEW_CLOUD_DIR}/occ upgrade"
  run-cmd "${cmd}"
}

function enableMaintenanceMode() {
  cmd="sudo -u apache php ${CLOUD_ROOT_DIR}/nextcloud/occ maintenance:mode --on"
  run-cmd "${cmd}"
  #sudo -u apache php /links/zinksrv/srv/nextcloud/occ maintenance:mode --on
}

TEST_MODE="true"
while getopts "r" Option
do
    case $Option in
  		r    ) TEST_MODE="false";;
    esac
done

echo "Executed commands are only printed start with $0 -r to execute commands"
stopServices
prepareNewNextcloud $@
startServices
# enableMaintenanceMode #probably done by occ-upgrade
startUpgrade
    

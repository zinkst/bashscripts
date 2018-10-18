#!/bin/bash
export CFG_SRC_DIR=/links/Gemeinsam/Burghalde/HeimNetz
export CLOUD_NAME="nextcloud"
export OLD_CLOUD_VER="12"
export NEW_CLOUD_VER="13.0.2"
export CLOUD_ROOT_DIR="/links/zinksrv/srv/"
export NEW_CLOUD_DIR="${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}/"
export OLD_CLOUD_DIR="${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${OLD_CLOUD_VER}/"

function stopServices () {
	systemctl stop php-fpm
	systemctl stop nginx
	systemctl stop mariadb
}

function startServices () {
	systemctl start mariadb
	systemctl start nginx
	systemctl start php-fpm
}
	
function prepareNewNextcloud () {
  wget https://download.nextcloud.com/server/releases/nextcloud-${NEW_CLOUD_VER}.zip -O ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}.zip
  if [ -d ${NEW_CLOUD_DIR}/config ]; 
  then
    echo "${NEW_CLOUD_DIR} already exists please check versions" 
    exit -1 
  else
    echo "This script is untested currently nothing is executed, only commands are printed"
    echo"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    cmd="rm ${CLOUD_ROOT_DIR}/${CLOUD_NAME}"
    echo $cmd
    cmd="unzip ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}.zip -d ${CLOUD_ROOT_DIR}/"
    echo $cmd
    cmd="mv ${CLOUD_ROOT_DIR}/${CLOUD_NAME} ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}"
    echo $cmd
    cmd="ln -sf ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER} ${CLOUD_ROOT_DIR}/${CLOUD_NAME}"
    echo $cmd
    cmd="chown apache:apache ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}/config"
    echo $cmd
    cmd="cp -prv ${OLD_CLOUD_DIR}/config/* ${NEW_CLOUD_DIR}/config/"
    echo $cmd
  fi	
		
}

function startUpgrade() {
  cmd="sudo -u apache php ${NEW_CLOUD_DIR}/occ upgrade"
  echo $cmd
}

stopServices
prepareNewNextcloud
startServices
startUpgrade
echo "This script is untested currently nothing is executed, only commands are printed"
echo"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    

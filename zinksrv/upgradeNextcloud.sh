#!/bin/bash
export CFG_SRC_DIR=/links/Gemeinsam/Burghalde/HeimNetz
export CLOUD_NAME="nextcloud"
export OLD_CLOUD_VER="13.0.2"
export NEW_CLOUD_VER="14.0.3"
export CLOUD_ROOT_DIR="/links/zinksrv/srv"
export NEW_CLOUD_DIR="${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}"
export OLD_CLOUD_DIR="${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${OLD_CLOUD_VER}"

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
  if ! [ -f  ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}.zip ]; 
  then 
    wget https://download.nextcloud.com/server/releases/nextcloud-${NEW_CLOUD_VER}.zip -O ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}.zip
  fi  
  if [ -d ${NEW_CLOUD_DIR}/config ]; 
  then
    echo "${NEW_CLOUD_DIR} already exists please check versions" 
    exit -1 
  else
    cmd="rm ${CLOUD_ROOT_DIR}/${CLOUD_NAME}"
    echo $cmd
    [ "$1" = "-r" ] && eval $cmd
    cmd="unzip ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}.zip -d ${CLOUD_ROOT_DIR}/"
    echo $cmd
    [ "$1" = "-r" ] && eval $cmd
    cmd="mv ${CLOUD_ROOT_DIR}/${CLOUD_NAME} ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}"
    echo $cmd
    [ "$1" = "-r" ] && eval $cmd
    cmd="ln -sf ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER} ${CLOUD_ROOT_DIR}/${CLOUD_NAME}"
    echo $cmd
    [ "$1" = "-r" ] && eval $cmd
    cmd="chown apache:apache ${CLOUD_ROOT_DIR}/${CLOUD_NAME}-${NEW_CLOUD_VER}/config"
    echo $cmd
    [ "$1" = "-r" ] && eval $cmd
    cmd="cp -prv ${OLD_CLOUD_DIR}/config/ca-bundle.crt ${OLD_CLOUD_DIR}/config/config.php ${NEW_CLOUD_DIR}/config/"
    echo $cmd
    [ "$1" = "-r" ] && eval $cmd
    ls -l ${CLOUD_ROOT_DIR}
  fi	
		
}

function startUpgrade() {
  cmd="sudo -u apache php ${NEW_CLOUD_DIR}/occ upgrade"
  echo $cmd
}

echo "Executed commands are only printed start with $0 -r to execute commands"
stopServices
prepareNewNextcloud $@
startServices
startUpgrade
    

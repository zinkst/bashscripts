#!/bin/bash
# username and password are sroted in ${root}/.my.cnf in section mysqldump
export NUM_BACKUPS=${NUM_BACKUPS:-2}
export SERVICE_NAME="vaultwarden"
export SRC_DIR="/links/zinksrv/srv/${SERVICE_NAME}"
export BACKUP_DIR=/links/zinksrv/sysbkp/${SERVICE_NAME}
export BACKUP_FILE=${SERVICE_NAME}Dir.tgz
source /links/bin/lib/dbBackupFunctions.sh


#main
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

TEST_MODE="false"
while getopts "ti" Option
do
    case $Option in
		t    ) TEST_MODE="true";;
    i    ) initServiceFolder    
    esac
done

ls -l ${BACKUP_DIR}
rotateFiles
backupServiceFolder
ls -l ${BACKUP_DIR}

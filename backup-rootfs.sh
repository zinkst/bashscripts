#!/bin/bash
# username and password are sroted in ${root}/.my.cnf in section mysqldump
export NUM_BACKUPS=2
export SERVICE_NAME="rootfs"
export SRC_DIR="/"
export BACKUP_DIR=/links/sysbkp/${SERVICE_NAME}
export BACKUP_FILE=${SERVICE_NAME}.tgz
source /links/bin/zinksrv/dbBackupFunctions.sh

function backupRootfs() {
  echo "starting backup on $(date +%H:%M:%S)"
  CMD="tar --selinux --acls --xattrs -cpf ${BACKUP_DIR}/${BACKUP_FILE} --directory / --use-compress-program=pigz --one-file-system --numeric-owner --exclude=proc/* --exclude=mnt/* --exclude=*/lost+found --exclude=tmp/* ."
  echo ${CMD}
  ($CMD)
  echo "finished backup on $(date +%H:%M:%S)"
}


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
backupRootfs
ls -l ${BACKUP_DIR}

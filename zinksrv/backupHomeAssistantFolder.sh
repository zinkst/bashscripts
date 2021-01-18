#!/bin/bash
# username and password are sroted in ${root}/.my.cnf in section mysqldump
export NUM_BACKUPS=2
export SRC_DIR="/links/zinksrv/srv/home-assist/home-assistant-config/"
export BACKUP_DIR=/links/zinksrv/sysbkp/homeAssistant
export BACKUP_FILE=homeAssitantDir.tgz
source /links/bin/zinksrv/dbBackupFunctions.sh


function backupHomeAssistant () {
   echo "creating new backup of Home Assistant Dir ${SRC_DIR}"
   CMD="tar -czf  ${BACKUP_DIR}/${BACKUP_FILE} --directory ${SRC_DIR} ."
   run-cmd "${CMD}"
}	


#main
DO_SHUTDOWN="false"
TEST_MODE="false"
while getopts "ht" Option
do
    case $Option in
        h    ) DO_SHUTDOWN="true";;
		t    ) TEST_MODE="true";;
    esac
done

ls -l ${BACKUP_DIR}
initDirWithBackupFiles
rotateFiles
backupHomeAssistant
ls -l ${BACKUP_DIR}
if [ ${DO_SHUTDOWN} == "true" ]; then
	CMD="shutdown -h now"
	echo ${CMD}
    eval ${CMD}
fi    


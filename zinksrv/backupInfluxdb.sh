#!/bin/bash
export BACKUP_DIR=/links/zinksrv/var/influx
export NUM_BACKUPS=2

source /links/bin/zinksrv/dbBackupFunctions.sh

function backupInflux () {
  echo "creating new database backup"
  if [ -d ${BACKUP_DIR}/latest ]; then
	  CMD="rm -rf ${BACKUP_DIR}/latest"
	  run-cmd "${CMD}"
  fi		
  mkdir -p ${BACKUP_DIR}/latest
  CMD="influx backup ${BACKUP_DIR}/latest -t $(cat /links/zinksrv/var/influxdb/root-token)"
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
echo TEST_MODE=${TEST_MODE}
initDirs
rotateDirs
backupInflux
ls -lR ${BACKUP_DIR}
if [ ${DO_SHUTDOWN} == "true" ]; then
	 CMD="shutdown -h now"
	 run-cmd ${CMD}
fi    


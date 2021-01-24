#!/bin/bash
# username and password are sroted in ${root}/.my.cnf in section mysqldump
export NUM_BACKUPS=3
export DB_NAME="nextcloud_db"
export BACKUP_DIR=/links/zinksrv/sysbkp/mariadb
export BACKUP_FILE=${DB_NAME}.sql.gz
source /links/bin/zinksrv/dbBackupFunctions.sh


function backupMariadb () {
   echo "creating new backup of Mariabdb ${DB_NAME}"
   CMD="/usr/bin/mariadb-dump --defaults-extra-file=/links/zinksrv/var/mysql/.my.cnf --databases ${DB_NAME} --single-transaction --create-options --default-character-set=utf8mb4 | gzip -9 > ${BACKUP_DIR}/${BACKUP_FILE}"
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
backupMariadb
ls -l ${BACKUP_DIR}
if [ ${DO_SHUTDOWN} == "true" ]; then
	CMD="shutdown -h now"
	echo ${CMD}
    eval ${CMD}
fi    


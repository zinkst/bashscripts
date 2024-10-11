#!/bin/bash

function run-cmd () {
  if [ ${TEST_MODE} == "false" ]; then
		eval "${1}"
	else
	  echo "${1}"
	fi	
}

###############################################
# functions for backing up complete folders 
# e.g. influx
###############################################
function initDirs () {
	initDirectory "${BACKUP_DIR}/latest"
	#CMD="mkdir -p ${BACKUP_DIR}/$((NUM_BACKUPS+1))" 
	#need to store this in a separate variable because it looks like this causes problems when $NUM_BACKUPS is used after
	LAST_INDEX=$((NUM_BACKUPS+1)) 
	initDirectory "${BACKUP_DIR}/${LAST_INDEX}"
	for i in $(seq 1 $NUM_BACKUPS) ; do
		echo " processing index ${i}"
		initDirectory ${BACKUP_DIR}/${i}
	done
	#ls -lR ${BACKUP_DIR}
}

function initDirectory () {
	if [ ! -d "${1}" ]; then
		CMD="mkdir -p "${1}" && touch "${1}/init" "
		run-cmd "${CMD}"
	fi	
}

function rotateDirs () {
	LAST_INDEX=$((NUM_BACKUPS+1))
	CMD="rm -rf ${BACKUP_DIR}/${LAST_INDEX}/*"
	run-cmd "${CMD}"
	for ((i=${NUM_BACKUPS};i>0;i-=1)) ; do 	
		echo " processing index ${i}"
		CMD="mv ${BACKUP_DIR}/${i}/* ${BACKUP_DIR}/$((i+1))/"
		run-cmd "${CMD}"
	done
	CMD="mv ${BACKUP_DIR}/latest/* ${BACKUP_DIR}/1/"
	run-cmd "${CMD}"
}	

###############################################
# Functions for packing folders 
###############################################
function initDirWithBackupFiles () {
	if [ ! -d "${BACKUP_DIR}" ]; then
		CMD="mkdir -p "${BACKUP_DIR}""
		run-cmd "${CMD}"
	fi 
	for i in  $(seq 1 $NUM_BACKUPS) ; do
		echo " processing index ${i}"
		if [ ! -f "${BACKUP_DIR}/${BACKUP_FILE}.${i}" ]; then
			CMD="touch ${BACKUP_DIR}/${BACKUP_FILE}.${i}"
			run-cmd "${CMD}"
		fi	
	done
}	

function rotateFiles () {
	LAST_INDEX=$((NUM_BACKUPS+1))
	if [ -f "${BACKUP_DIR}/${BACKUP_FILE}.${LAST_INDEX}" ]; then
		rm ${BACKUP_DIR}/${BACKUP_FILE}.${LAST_INDEX}
	fi	
	for ((i=${NUM_BACKUPS};i>0;i-=1)) ; do
		echo " processing index ${i}"
		CMD="mv ${BACKUP_DIR}/${BACKUP_FILE}.${i} ${BACKUP_DIR}/${BACKUP_FILE}.$((i+1))"
		run-cmd "${CMD}"
	done
	CMD="mv ${BACKUP_DIR}/${BACKUP_FILE} ${BACKUP_DIR}/${BACKUP_FILE}.1"
	run-cmd "${CMD}"
}	


function createBackupSystemdService() {
if [ -f "/etc/systemd/system/backup-${SERVICE_NAME}.service" ]; then
   echo "systemd service ${SERVICE_NAME} already exists"
else	
	
cat << EOF > /etc/systemd/system/backup-${SERVICE_NAME}.service
[Unit]
Description=Backup ${SERVICE_NAME} data folder

[Service]
Type=simple
ExecStart=/links/bin/zinksrv/backup-${SERVICE_NAME}.sh

EOF
fi
}

function createBackupSystemdTimer() {
if [ -f "/etc/systemd/system/backup-${SERVICE_NAME}.timer" ]; then
   echo "systemd timer ${SERVICE_NAME} already exists"
else	
	
cat << EOF > /etc/systemd/system/backup-${SERVICE_NAME}.timer
[Unit]
Description=Timer for Backup ${SERVICE_NAME} data folder

[Timer]
OnCalendar=*-*-* 02:35:00
Persistent=True
Unit=backup-${SERVICE_NAME}.service

[Install]
WantedBy=basic.target
EOF

  systemctl enable backup-${SERVICE_NAME}.timer
fi
}

function backupServiceFolder () {
   echo "creating new backup of ${SERVICE_NAME} Dir ${SRC_DIR}"
   CMD="tar -czf  ${BACKUP_DIR}/${BACKUP_FILE} --directory ${SRC_DIR} ."
   run-cmd "${CMD}"
}	

function initServiceFolder() {
  initDirWithBackupFiles
  createBackupSystemdService
  createBackupSystemdTimer
}
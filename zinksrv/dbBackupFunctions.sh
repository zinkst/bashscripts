#!/bin/bash

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

function run-cmd () {
  if [ ${TEST_MODE} == "false" ]; then
		eval "${1}"
	else
	  echo "${1}"
	fi	
}


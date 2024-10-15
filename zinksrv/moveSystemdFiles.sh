#!/bin/bash
set -euo pipefail
# variables
HOSTNAME=$(hostname -s)
SYSTEMD_DIR="/etc/systemd/system"
SYSTEMD_TARGET_DIR="/links/${HOSTNAME}/etc/systemd/system"

function run-cmd () {
  if [ ${TEST_MODE} == "false" ]; then
		eval "${1}"
	else
	  echo "${1}"
	fi	
}

function moveSystemdFiles() {
  TIMER_SERVICES=(
	"backup-home-assistant"
	"backup-influx-db"
	"backup-rootfs"
	"backup-vaultwarden"
	"backup-nextcloud-quadlet"
	"restic_bkp_qnap-nas"
	"zinksrv_usb_backup"
  )	
  SERVICES=(
	home-assist
	node-red
	zigbee2mqtt
  )
  for svc in ${TIMER_SERVICES[@]}; do
	SERVICE_TYPES=( 
		"service" 
		"timer" 
	)
	for svc_type in ${SERVICE_TYPES[@]}; do
		moveService ${svc}.${svc_type}
	done	
  done
  for  svc in ${SERVICES[@]}; do
	moveService ${svc}.service
  done
}

function moveService() {
	SERVICE_TO_MOVE=${1}
	echo "Move service ${SERVICE_TO_MOVE}"
	if [ -L ${SYSTEMD_DIR}/${SERVICE_TO_MOVE} ]; then
		echo "${SYSTEMD_DIR}/${SERVICE_TO_MOVE} is already a symlink"
	else	
		if [ -f ${SYSTEMD_DIR}/${SERVICE_TO_MOVE} ] && [ ! -f ${SYSTEMD_TARGET_DIR}/${SERVICE_TO_MOVE} ]; then
			cmd="mv ${SYSTEMD_DIR}/${SERVICE_TO_MOVE} ${SYSTEMD_TARGET_DIR}/${SERVICE_TO_MOVE}"
			run-cmd "${cmd}"
			cmd="ln -sf ${SYSTEMD_TARGET_DIR}/${SERVICE_TO_MOVE} ${SYSTEMD_DIR}/${SERVICE_TO_MOVE}"
			run-cmd "${cmd}"
		fi
	fi

}

#main
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
TEST_MODE="false"
while getopts "t" Option
do
    case $Option in
		t    ) TEST_MODE="true";;
    esac
done
moveSystemdFiles
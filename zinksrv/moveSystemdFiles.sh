#!/bin/bash
# set -euo pipefail
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

function moveFiles() {
  TIMER_SERVICES=(
	"backup-home-assistant"
	"backup-influx-db"
	"backup-rootfs"
	"backup-vaultwarden"
	"backup-nextcloud"
	"backup-grafana"
	"backup-zigbee2mqtt"
	"backup-caddy"
	"restic_bkp_qnap-nas"
	"zinksrv_usb_backup"
  )
  for svc in ${TIMER_SERVICES[@]}; do
	SERVICE_TYPES=( 
		"service" 
		"timer" 
	)
	for svc_type in ${SERVICE_TYPES[@]}; do
		# cmd="rm ${SYSTEMD_DIR}/${svc}.${svc_type}" 
		# run-cmd "$cmd"
		# cmd="cp ${SYSTEMD_TARGET_DIR}/${svc}.${svc_type} ${SYSTEMD_DIR}/" 
		# run-cmd "$cmd"
		cmd="systemctl is-active ${svc}.${svc_type}" 
		run-cmd "$cmd"
	done	
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
moveFiles
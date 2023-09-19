#!/bin/bash
# variables
export SRC_ROOT="/"
export TGT_ROOT="/run/media/BKP_ZINK_USB_2-part1"
export RESTIC_PATH="zinksrv_restic"
export RESTIC_REPOSITORY="${TGT_ROOT}/${RESTIC_PATH}"
export RESTIC_PASSWORD_FILE=/links/sysbkp/restic_pwd_file
export LOG_ROOT="/links/zinksrv/sysbkp/restic_logs/${RESTIC_PATH}"
#RSYNC_PARAMS="-av -A --one-file-system --exclude-from /links/data/zinksrv/rsync_exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
CORRECTHOST="zinksrv"
index="1 2 3 4 5 6 7 8 9"
index="2 4"
#MINS_SINCE_LASTRUN=-1500
#USE_SSH=false
#CHECK_LASTRUN=false


Directories[1]="local/data/zinksrv/Photos"
Directories[2]="local/data/zinksrv/FamilienVideos"
Directories[3]="local/data/zinksrv/Musik"
Directories[4]="local/data/zinksrv/persdata"
# Directories[5]="local/data/kinder2"
# Directories[6]="local/data/zink-pc3"
# Directories[7]="local/data/zink-e595"
# Directories[8]="local/data/zink-w530"
# Directories[9]="local/data/zink-pc4"


. /links/bin/bkp_functions.sh

function installRestic {
	dnf -y install rclone rclone-browser restic
}

function initializeBackupStore {
	restic init
	# zinksrv usb-2
	# created restic repository ba8a87ebb8 at /run/media/BKP_ZINK_USB_2-part1/zinksrv_restic
}


ShowResticSnapshots () 
{
  if mountpoint -q "${TGT_ROOT}"; then
	cmd="restic snapshots"
	echo "$cmd"
	eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
  else
    echo "${TGT_ROOT} not mounted skipping" | tee -a ${LOG_ROOT}${LOGFILENAME}
  fi
}

doResticWithTgtDirAndMountTestFile () 
{
  if mountpoint -q "${TGT_ROOT}"; then
  	for ind in $index
	do
		cmd="restic ls \"${SRC_ROOT}${Directories[ind]}/\""
		echo "$cmd"
		eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
    done		
  else
    echo "${TGT_ROOT} not mounted skipping" | tee -a ${LOG_ROOT}${LOGFILENAME}
  fi
}

mkdir -p "${LOG_ROOT}"
setLogfileName ${LOGFILENAME}
checkCorrectHost
echo LogFileName: ${LOG_ROOT}${LOGFILENAME}
doResticWithTgtDirAndMountTestFile
#ShowResticSnapshots
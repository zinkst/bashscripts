#!/bin/bash
# variables
export SRC_ROOT="/"
export TGT_ROOT="/run/media/BKP_ZINK_USB"
export TGT_DEVICE="/dev/disk/by-id/wwn-0x50014ee0aeb36c58-part1"
export RESTIC_PATH="zinksrv_restic"
export RESTIC_REPOSITORY="${TGT_ROOT}/${RESTIC_PATH}"
export RESTIC_PASSWORD_FILE=/links/etc/restic/restic_pwd_file
LOGFILENAME=$(basename "${0}" .sh)
export LOG_ROOT="/links/Not4Backup/BackupLogs/${LOGFILENAME}/"
mkdir -p ${LOG_ROOT}
CORRECTHOST="zinksrv"
index="1 2 3 4 5 6 7 8 9"

Directories[1]="local/data/zinksrv/Photos"
Directories[2]="local/data/zinksrv/FamilienVideos"
Directories[3]="local/data/zinksrv/Musik"
Directories[4]="local/data/zinksrv/persdata"
Directories[5]="local/data/kinder2"
Directories[6]="local/data/zink-pc3"
Directories[7]="local/data/zink-e595"
Directories[8]="local/data/zink-w530"
Directories[9]="local/data/zink-pc4"

source /links/bin/lib/bkp_functions.sh
source /links/bin/lib/resticFunctions.sh

# main
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
mkdir -p "${LOG_ROOT}"
# setLogfileName ${LOGFILENAME}
checkCorrectHost
prepareRsyncConfig "${LOGFILENAME}"
mkdir -p "${LOG_ROOT}"
logrotate -f /links/etc/logrotate.d/${LOGFILENAME}_logs
LOGFILENAME=${LOGFILENAME}.log
echo LogFileName: ${LOG_ROOT}${LOGFILENAME}

powerOnTasmotaPlug "hama-4fach-01" "Power2"
echo "mounting ${TGT_DEVICE}"
udisksctl mount -b ${TGT_DEVICE}
echo "waiting 10 seconds" && sleep 10
# echo "intializing Backup store" && initializeBackupStore
echo "starting  backup" && doResticWithTgtDirAndMountTest
doResticForgetKeepOnlyLastNSnapshots 8
ShowResticSnapshots
df -h ${TGT_ROOT} | tee -a ${LOG_ROOT}${LOGFILENAME}
udisksctl unmount -b ${TGT_DEVICE}
echo "waiting 10 seconds" && sleep 10
# Power Off USB Backup
curl -s http://hama-4fach-01/cm?cmnd=Power2%20Off && echo
echo "finished"
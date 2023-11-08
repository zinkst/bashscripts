#!/bin/bash
# variables
export SRC_ROOT="/"
export TGT_ROOT="/run/media/BKP_ZINK_USB"
export TGT_DEVICE="/dev/disk/by-id/wwn-0x50014ee0aeb36c58-part1"
export RESTIC_PATH="zinksrv_restic"
export RESTIC_REPOSITORY="${TGT_ROOT}/${RESTIC_PATH}"
export RESTIC_PASSWORD_FILE=/links/sysbkp/restic_pwd_file
LOGFILENAME=$(basename "${0}" .sh)
export LOG_ROOT="/links/zinksrv/sysbkp/restic_logs/${LOGFILENAME}/"
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


. /links/bin/resticFunctions.sh

# main
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
mkdir -p "${LOG_ROOT}"
setLogfileName ${LOGFILENAME}
checkCorrectHost
echo LogFileName: ${LOG_ROOT}${LOGFILENAME}

powerOnTasmotaPlug "hama-4fach-01" "Power2"
echo "mounting ${TGT_DEVICE}"
udisksctl mount -b ${TGT_DEVICE}
echo "waiting 10 seconds" && sleep 10
echo "starting  backup"
doResticWithTgtDirAndMountTest
ShowResticSnapshots
df -h ${TGT_ROOT}
udisksctl unmount -b ${TGT_DEVICE}
echo "waiting 10 seconds" && sleep 10
# Power Off USB Backup
curl -s http://hama-4fach-01/cm?cmnd=Power2%20Off && echo
echo "finished"
#!/bin/bash
# variables
export SRC_ROOT="/"
export TGT_ROOT="/run/media/BKP_ZINK_USB_2-part1"
export RESTIC_PATH="zinksrv_restic"
export RESTIC_REPOSITORY="${TGT_ROOT}/${RESTIC_PATH}"
export RESTIC_PASSWORD_FILE=/links/sysbkp/restic_pwd_file
export LOG_ROOT="/links/zinksrv/sysbkp/restic_logs/${RESTIC_PATH}"
LOGFILENAME=$(basename "${0}" .sh)
CORRECTHOST="zinksrv"
index="1 2 3 4 5 6 7 8 9"
index="2 4"


Directories[1]="local/data/zinksrv/Photos"
Directories[2]="local/data/zinksrv/FamilienVideos"
Directories[3]="local/data/zinksrv/Musik"
Directories[4]="local/data/zinksrv/persdata"


. /links/bin/resticFunctions.sh

#main
mkdir -p "${LOG_ROOT}"
setLogfileName ${LOGFILENAME}
checkCorrectHost
echo LogFileName: ${LOG_ROOT}${LOGFILENAME}
doResticWithTgtDirAndMountTestFile
ShowResticSnapshots
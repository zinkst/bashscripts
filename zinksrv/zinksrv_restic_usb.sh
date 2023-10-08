#!/bin/bash
# variables
export SRC_ROOT="/"
export TGT_ROOT="/run/media/BKP_ZINK_USB"
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
mkdir -p "${LOG_ROOT}"
setLogfileName ${LOGFILENAME}
checkCorrectHost
echo LogFileName: ${LOG_ROOT}${LOGFILENAME}
#initializeBackupStore
doResticWithTgtDirAndMountTest
ShowResticSnapshots
df -h ${TGT_ROOT}
#mountRestic 3
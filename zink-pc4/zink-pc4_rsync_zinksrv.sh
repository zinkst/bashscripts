#!/bin/bash
# variables
SRC_ROOT="/"
TGT_ROOT="/remote/zinksrv/nfs4/"
LOGFILENAME=$(basename "${0}" .sh)
LOG_ROOT="/links/Not4Backup/BackupLogs/${LOGFILENAME}/"
RSYNC_PARAMS="-av -A --one-file-system --exclude-from /links/etc/my-etc/rsync/rsync_exclude.txt"
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
CHECK_LASTRUN=false
REMOTEMOUNTPOINT=${TGT_ROOT}
TRY_MOUNT_TGT="true"

SSH_HOST="zinksrv"
SSH_TGT_ROOT="root@${SSH_HOST}:/local/data/zink-ry4650g/"
USE_SSH=false

CORRECTHOST=$(hostname -s)
index="1"


Directories[1]="local/data/zink-pc4"
TargetDir[1]="data/zink-pc4/data/zink-pc4"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
# Directories[2]="local/data_hdd/zink-ry4650g"
# TargetDir[2]="data/zink-ry4650g/data_hdd/zink-ry4650g"
# MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"


. /links/bin/lib/bkp_functions.sh

# main routine
prepareBackupLogs
prepareRsyncConfig "${LOGFILENAME}"
mkdir -p "${LOG_ROOT}"
logrotate -f /links/etc/logrotate.d/${LOGFILENAME}_logs
LOGFILENAME=${LOGFILENAME}.log
echo LOG_PATH=${LOG_ROOT}${LOGFILENAME}
checkCorrectHost
rsyncBkpParamCheck $@
if [ ${CHECK_LASTRUN} == true ]
then
	checkLastRun
fi
doRsyncWithTgtDirAndMountTestFile
updateLastRunFile
umount ${REMOTEMOUNTPOINT}

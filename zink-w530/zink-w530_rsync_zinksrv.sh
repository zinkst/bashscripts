#!/bin/bash
# variables
TGT_ROOT="/remote/zinksrv/"
REMOTEMOUNTPOINT=${TGT_ROOT}
NFS_SERVER_URI="zinksrv:/" 
CORRECTHOST="zink-w530"
#SRC_ROOT="/remote/marion/cifs/"
# with CIFS there are permissions problems also when running as root
SRC_ROOT="/"
LOGFILENAME=$(basename "${0}" .sh)
LOG_ROOT="/links/Not4Backup/BackupLogs/${LOGFILENAME}/"
RSYNC_PARAMS="-av -A --one-file-system --exclude-from /links/etc/my-etc/rsync/rsync_exclude.txt"
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
TRY_MOUNT_TGT="true"
#index="1 2 3 4"
index="1"
Directories[1]="local/data/${CORRECTHOST}"
TargetDir[1]="data/${CORRECTHOST}/data"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
# Directories[2]="${CORRECTHOST}/homes"
# TargetDir[2]="data/${CORRECTHOST}/homes"
# MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"
# Directories[3]="data/${CORRECTHOST}/persdata/Henry-local"
# TargetDir[3]="data/${CORRECTHOST}/persdata/Henry-local"
# MountTestFile[3]=${TGT_ROOT}"data/doNotDelete"
# Directories[4]="${CORRECTHOST}/sysbkp"
# TargetDir[4]="data/${CORRECTHOST}/sysbkp"
# MountTestFile[4]=${TGT_ROOT}"data/doNotDelete"

. /root/bin/lib/bkp_functions.sh

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

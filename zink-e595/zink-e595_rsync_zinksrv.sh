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

# SSH_HOST="zinksrv"
# SSH_TGT_ROOT="root@${SSH_HOST}:/local/data/kinder/"
# USE_SSH=false

CORRECTHOST="zink-e595"
MEDIA_SYNC_YEAR=2024
index="1 2 3 4 5 6 7 8 9 10"


Directories[1]="local/data/${CORRECTHOST}/lokal"
TargetDir[1]="data/${CORRECTHOST}/data/lokal"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
Directories[2]="local/ssd-data/Photos/unsorted"
TargetDir[2]="data/${CORRECTHOST}/ssd-data/Photos/unsorted"
MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"
Directories[3]="local/data/${CORRECTHOST}/homes"
TargetDir[3]="data/${CORRECTHOST}/data/homes"
MountTestFile[3]=${TGT_ROOT}"data/doNotDelete"
Directories[4]="local/data/${CORRECTHOST}/Musik"
TargetDir[4]="data/zinksrv/Musik"
MountTestFile[4]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[4]=false
Directories[5]="local/data/${CORRECTHOST}/FamilienVideos/Familie-Zink-Videos/${MEDIA_SYNC_YEAR}"
TargetDir[5]="data/zinksrv/FamilienVideos/Familie-Zink-Videos/${MEDIA_SYNC_YEAR}"
MountTestFile[5]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[5]=true
Directories[6]="local/ssd-data/Photos/${MEDIA_SYNC_YEAR}"
TargetDir[6]="data/zinksrv/Photos/Sammlung/${MEDIA_SYNC_YEAR}"
MountTestFile[6]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[6]=false
Directories[7]="local/data/${CORRECTHOST}/FamilienVideos/FamilienVideos für Handy/Videos ${MEDIA_SYNC_YEAR}"
TargetDir[7]="data/Not4Backup/shared/FamilienVideos für Handy/Videos ${MEDIA_SYNC_YEAR}"
MountTestFile[7]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[7]=true
Directories[8]="local/ssd-data/FamilienVideos/unsorted"
TargetDir[8]="data/${CORRECTHOST}/ssd-data/FamilienVideos/unsorted"
MountTestFile[8]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[8]=true
Directories[9]="local/data/${CORRECTHOST}/Photos/Converted/1920"
TargetDir[9]="data/zinksrv/Photos/Converted/1920"
MountTestFile[9]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[9]=true
Directories[10]="local/data/${CORRECTHOST}/FamilienVideos/Favoriten-Familie-Zink-Videos/${MEDIA_SYNC_YEAR}"
TargetDir[10]="data/zinksrv/FamilienVideos/Favoriten-Familie-Zink-Videos/${MEDIA_SYNC_YEAR}"
MountTestFile[10]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[10]=true


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

#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="zinksrv"
TGT_ROOT="/run/media/karl/BACKUP_ROEHM2/"
LOGFILENAME=$(basename "${0}" .sh).log
LOG_ROOT="/local/backup/BackupLogs/$(basename "${0}" .sh)/"

mkdir -p ${LOG_ROOT}
RSYNC_PARAMS="-av --one-file-system --exclude-from /links/etc/my-etc/rsync/rsync_exclude.txt"
# RSYNC_PARAMS="-av --one-file-system"
CORRECTHOST="karl-laptop"
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
REMOTEMOUNTPOINT=${TGT_ROOT}
TRY_MOUNT_TGT="true"
index="1 2"

Directories[1]="home/"
TargetDir[1]="Karl-Laptop/linux/home"
MountTestFile[1]="${TGT_ROOT}doNotDelete"
Directories[2]="local/backup/karl-laptop/sysbkp"
TargetDir[2]="Karl-Laptop/linux/sysbkp"
MountTestFile[2]="${TGT_ROOT}doNotDelete"



. /links/bin/lib/bkp_functions.sh

# main routine
checkCorrectHost
rsyncBkpParamCheck $@
logrotate -f /links/etc/logrotate.d/karl-laptop_rsync_zinksrv_logs
doRsyncWithTgtDirAndMountTestFile

# umount ${REMOTEMOUNTPOINT}

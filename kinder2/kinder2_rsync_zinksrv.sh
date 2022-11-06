#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="zinksrv"
SSH_TGT_ROOT="root@${SSH_HOST}:/local/data/kinder2/"
TGT_ROOT="/remote/zinksrv/nfs4/"
LOG_ROOT="/links/rsync_folder/"
CORRECTHOST="kinder2"
RSYNC_PARAMS="-av -A -X --one-file-system --exclude-from /links/bin/${CORRECTHOST}/rsync_exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
REMOTEMOUNTPOINT=${TGT_ROOT}
TRY_MOUNT_TGT="true"
index="1 2"

Directories[1]="local/data/kinder2"
TargetDir[1]="data/kinder2/data"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
Directories[2]="local/backup/kinder2"
TargetDir[2]="data/kinder2/backup/kinder2"
MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"


. /links/bin/bkp_functions.sh

# main routine
setLogfileName ${LOGFILENAME}
checkCorrectHost
rsyncBkpParamCheck $@
if [ ${CHECK_LASTRUN} == true ]
then
	checkLastRun
fi
if [ ${USE_SSH} == true ]
then
    if ping -c 1 ${SSH_HOST} # &> /dev/null
	then
		echo "exit code of ping ${SSH_HOST} = $?; doing rsync"
		doRsyncWithTgtDir
	else
		echo "exit code of ping ${SSH_HOST} = $?; exiting and not doing rsync"
	fi
else	
	doRsyncWithTgtDirAndMountTestFile
fi	
updateLastRunFile
umount ${REMOTEMOUNTPOINT}

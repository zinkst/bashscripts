#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="zinksrv"
SSH_TGT_ROOT="root@${SSH_HOST}:/local/data/zink-pc3/"
TGT_ROOT="/remote/zinksrv/nfs4/"
LOG_ROOT="/links/sysbkp/rsync/"
RSYNC_PARAMS="-av -A -one-file-system --exclude-from /links/sysbkp/rsync/rsync_exclude.txt"
CORRECTHOST="zink-pc3"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
REMOTEMOUNTPOINT=${TGT_ROOT}
TRY_MOUNT_TGT="true"
index="1"

Directories[1]="local/data/${CORRECTHOST}"
TargetDir[1]="data/${CORRECTHOST}/data"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"

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

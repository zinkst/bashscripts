#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="zinksrv"
SSH_TGT_ROOT="root@${SSH_HOST}:/local/data/zink-ry4650g/"
TGT_ROOT="/remote/zinksrv/nfs4/"
LOG_ROOT="/links/sysbkp/rsync/"
RSYNC_PARAMS="-av --one-file-system --exclude-from /links/sysbkp/rsync_exclude.txt"
CORRECTHOST="zink-ry4650g"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
REMOTEMOUNTPOINT=${TGT_ROOT}
TRY_MOUNT_TGT="true"
index="1 2"

Directories[1]="local/data/zink-ry4650g"
TargetDir[1]="data/zink-ry4650g/data/zink-ry4650g"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
Directories[2]="local/data_hdd/zink-ry4650g"
TargetDir[2]="data/zink-ry4650g/data_hdd/zink-ry4650g"
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

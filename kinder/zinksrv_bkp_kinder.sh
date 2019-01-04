#!/bin/bash
# variables
TGT_ROOT="/"
SSH_HOST="zinksrv"
SSH_TGT_ROOT="root@${SSH_HOST}:/local/data/kinder/"
SRC_ROOT="/remote/zinksrv/nfs4/"
LOG_ROOT="/links/sysbkp/rsync/"
RSYNC_PARAMS="-av --one-file-system --exclude-from /links/sysbkp/rsync_exclude.txt"
CORRECTHOST="kinder"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
REMOTEMOUNTPOINT=${SRC_ROOT}
TRY_MOUNT_TGT="true"
index="1 2"

Directories[1]="data/zinksrv/Photos/Sammlung"
TargetDir[1]="local/data_hdd/bkp_zinksrv/Photos/Sammlung"
MountTestFile[1]=${SRC_ROOT}"data/doNotDelete"
Directories[2]="data/zinksrv/FamilienVideos"
TargetDir[2]="local/data_hdd/bkp_zinksrv/FamilienVideos"
MountTestFile[2]=${SRC_ROOT}"data/doNotDelete"


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

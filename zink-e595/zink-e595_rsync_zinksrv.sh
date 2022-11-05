#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="zinksrv"
SSH_TGT_ROOT="root@${SSH_HOST}:/local/data/kinder/"
TGT_ROOT="/remote/zinksrv/nfs4/"
LOG_ROOT="/links/sysbkp/rsync/"
RSYNC_PARAMS="-av --one-file-system --exclude-from /links/sysbkp/rsync/rsync_exclude.txt"
CORRECTHOST="zink-e595"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
REMOTEMOUNTPOINT=${TGT_ROOT}
TRY_MOUNT_TGT="true"
index="1 2 3 4 5 6 7 8"

Directories[1]="local/data/${CORRECTHOST}/lokal"
TargetDir[1]="data/${CORRECTHOST}/data/lokal"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
Directories[2]="local/ssd-data/Photos/unsorted"
TargetDir[2]="data/${CORRECTHOST}/ssd-data/Photos/unsorted"
MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"
Directories[3]="local/data/${CORRECTHOST}/homes"
TargetDir[3]="data/${CORRECTHOST}/data/homes/"
MountTestFile[3]=${TGT_ROOT}"data/doNotDelete"
Directories[4]="local/data/${CORRECTHOST}/Musik"
TargetDir[4]="data/zinksrv/Musik/"
MountTestFile[4]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[4]=false
Directories[5]="local/data/${CORRECTHOST}/FamilienVideos/Familie-Zink-Videos/2022"
TargetDir[5]="data/zinksrv/FamilienVideos/Familie-Zink-Videos/2022"
MountTestFile[5]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[5]=true
Directories[6]="local/ssd-data/Photos/2022"
TargetDir[6]="data/zinksrv/Photos/Sammlung/2022"
MountTestFile[6]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[6]=false
Directories[7]="local/data/${CORRECTHOST}/Photos/Converted"
TargetDir[7]="data/zinksrv/Photos/Converted"
MountTestFile[7]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[7]=true
Directories[8]="local/ssd-data/FamilienVideos/unsorted"
TargetDir[8]="data/${CORRECTHOST}/ssd-data/FamilienVideos/unsorted"
MountTestFile[8]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[8]=true


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

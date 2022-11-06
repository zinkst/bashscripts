#!/bin/bash
# variables
TGT_ROOT="/remote/zinksrv/nfs4/"
REMOTEMOUNTPOINT=${TGT_ROOT}
NFS_SERVER_URI="zinksrv:/" 
CORRECTHOST="zink-w530"
#SRC_ROOT="/remote/marion/cifs/"
# with CIFS there are permissions problems also when running as root
SRC_ROOT="/"
LOG_ROOT="${SRC_ROOT}/local/data/rsync/logs"
RSYNC_PARAMS="-av -A -X --one-file-system --exclude-from ${SRC_ROOT}/local/data/rsync/exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
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
Directories[2]="${CORRECTHOST}/homes"
TargetDir[2]="data/${CORRECTHOST}/homes"
MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"
Directories[3]="${CORRECTHOST}/persdata/Henry-local"
TargetDir[3]="data/${CORRECTHOST}/persdata/Henry-local"
MountTestFile[3]=${TGT_ROOT}"data/doNotDelete"
Directories[4]="${CORRECTHOST}/sysbkp"
TargetDir[4]="data/${CORRECTHOST}/sysbkp"
MountTestFile[4]=${TGT_ROOT}"data/doNotDelete"

. /root/bin/bkp_functions.sh

setLogfileName ${LOGFILENAME}
checkCorrectHost
rsyncBkpParamCheck $@
cmd="mount ${NFS_SERVER_URI} ${REMOTEMOUNTPOINT}"
echo $cmd
eval $cmd

if [ ${CHECK_LASTRUN} == true ]
then
	checkLastRun
fi
if [ ${USE_SSH} == true ]
then
    doRsyncWithTgtDir
else	
	doRsyncWithTgtDirAndMountTestFile
fi	
updateLastRunFile
umount ${REMOTEMOUNTPOINT}

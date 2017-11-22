#!/bin/bash
# variables
TGT_ROOT="/remote/zinksrv/nfs4/"
REMOTEMOUNTPOINT=${TGT_ROOT}
NFS_SERVER_URI="zinksrv:/" 
#SRC_ROOT="/remote/marion/cifs/"
# with CIFS there are permissions problems also when running as root
SRC_ROOT="/links/"
LOG_ROOT="${SRC_ROOT}/marion-pc/rsync/"
RSYNC_PARAMS="-av --one-file-system --exclude-from ${SRC_ROOT}marion-pc/rsync/exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
CORRECTHOST="marion-pc"
TRY_MOUNT_TGT="true"
index="1 2 3 4"

Directories[1]="marion-pc/persdata/Marion/MarionsPhotos"
TargetDir[1]="data/marion-pc/persdata/Marion/MarionsPhotos"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
Directories[2]="marion-pc/homes"
TargetDir[2]="data/marion-pc/homes"
MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"
Directories[3]="marion-pc/persdata/Marion/marion-marion-pc"
TargetDir[3]="data/marion-pc/persdata/Marion/marion-marion-pc"
MountTestFile[3]=${TGT_ROOT}"data/doNotDelete"
Directories[4]="marion-pc/sysbkp"
TargetDir[4]="data/marion-pc/sysbkp"
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

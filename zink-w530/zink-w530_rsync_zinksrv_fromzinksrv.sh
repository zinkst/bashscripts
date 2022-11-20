#!/bin/bash
# variables
TGT_ROOT="/remote/zinksrv/nfs4/data/"
#SRC_ROOT="/remote/marion/cifs/"
# with CIFS there are permissions problems also when running as root
SRC_ROOT="/links/"
LOG_ROOT="${SRC_ROOT}/marion-pc/rsync/"
RSYNC_PARAMS="-av -A --one-file-system --exclude-from ${SRC_ROOT}marion-pc/rsync/exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
CORRECTHOST="marion-pc"
index="1 2 3"

Directories[1]="marion-pc/persdata/Marion/MarionsPhotos"
TargetDir[1]="marion-pc/persdata/Marion/MarionsPhotos"
MountTestFile[1]=${TGT_ROOT}"doNotDelete"
Directories[2]="marion-pc/homes"
TargetDir[2]="marion-pc/homes"
MountTestFile[2]=${TGT_ROOT}"doNotDelete"
Directories[3]="marion-pc/persdata/Marion/marion-marion-pc"
TargetDir[3]="marion-pc/persdata/Marion/marion-marion-pc"
MountTestFile[3]=${TGT_ROOT}"doNotDelete"

. /root/bin/bkp_functions.sh

setLogfileName ${LOGFILENAME}
checkCorrectHost
rsyncBkpParamCheck $@
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

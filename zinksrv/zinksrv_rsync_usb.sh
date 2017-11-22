#!/bin/bash
# variables
SRC_ROOT="/"
TGT_ROOT="/run/media/zinks/BKP_ZINK/"
LOG_ROOT="/links/zinksrv/rsync_logs/"
RSYNC_PARAMS="-av --one-file-system --exclude-from /links/data/zinksrv/rsync_exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
CORRECTHOST="zinksrv"
index="1 2 5 6 7"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false


Directories[1]="local/data/zinksrv"
TargetDir[1]="same"
MountTestFile[1]=${TGT_ROOT}"doNotDelete"
Directories[2]="local/data/Other-Systems"
TargetDir[2]="same"
MountTestFile[2]=${TGT_ROOT}"doNotDelete"
Directories[3]="local/ntfs_c"
TargetDir[3]="same"
MountTestFile[3]=${TGT_ROOT}"doNotDelete"
Directories[4]="local/data2"
TargetDir[4]="same"
MountTestFile[4]=${TGT_ROOT}"doNotDelete"
AllowDelete[4]=true
Directories[5]="local/ntfsdata"
TargetDir[5]="same"
MountTestFile[5]=${TGT_ROOT}"doNotDelete"
AllowDelete[5]=true
Directories[6]="local/data/marion-pc"
TargetDir[6]="same"
MountTestFile[6]=${TGT_ROOT}"doNotDelete"
AllowDelete[6]=true
Directories[7]="local/perfcache"
TargetDir[7]="same"
MountTestFile[7]=${TGT_ROOT}"doNotDelete"
AllowDelete[7]=true

. /links/bin/bkp_functions.sh

setLogfileName ${LOGFILENAME}
checkCorrectHost
rsyncBkpParamCheck $@
if [ ${CHECK_LASTRUN} == true ]
then
	checkLastRun
fi
doRsyncWithTgtDirAndMountTestFile
updateLastRunFile



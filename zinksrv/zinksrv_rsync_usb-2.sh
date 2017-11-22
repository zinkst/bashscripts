#!/bin/bash
# variables
SRC_ROOT="/"
TGT_ROOT="/run/media/zinks/BKP_ZINK_USB2/"
LOG_ROOT="/links/zinksrv/rsync_logs/"
RSYNC_PARAMS="-av --one-file-system --exclude-from /links/data/zinksrv/rsync_exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
CORRECTHOST="zinksrv"
index="2 3 4 5"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false


Directories[1]="local/data/zinksrv"
TargetDir[1]="same"
MountTestFile[1]=${TGT_ROOT}"doNotDelete"
AllowDelete[1]=true

Directories[2]="local/data/marion-pc"
TargetDir[2]="same"
MountTestFile[2]=${TGT_ROOT}"doNotDelete"
AllowDelete[2]=true

Directories[3]="local/data/Other-Systems"
TargetDir[3]="same"
MountTestFile[3]=${TGT_ROOT}"doNotDelete"
AllowDelete[3]=true

Directories[4]="local/data/kinder"
TargetDir[4]="same"
MountTestFile[4]=${TGT_ROOT}"doNotDelete"
AllowDelete[4]=true

Directories[5]="local/perfcache"
TargetDir[5]="same"
MountTestFile[5]=${TGT_ROOT}"doNotDelete"
AllowDelete[5]=true


Directories[6]="local/ntfs_c"
TargetDir[6]="same"
MountTestFile[6]=${TGT_ROOT}"doNotDelete"

Directories[7]="local/ntfsdata"
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



#!/bin/bash
# variables
SRC_ROOT="/"
TGT_ROOT="/run/media/marion/FILME/"
LOG_ROOT="/links/zinksrv/rsync_logs/"
RSYNC_PARAMS="-av -A --one-file-system --exclude-from /links/data/zinksrv/rsync_exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
CORRECTHOST="zinksrv"
index="1"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false


Directories[1]="local/data/zinksrv/Filme"
TargetDir[1]="Filme"
MountTestFile[1]=${TGT_ROOT}"doNotDelete"

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



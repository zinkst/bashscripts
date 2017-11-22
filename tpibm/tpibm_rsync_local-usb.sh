#!/bin/bash
# variables
SRC_ROOT="/"
TGT_ROOT="/"
LOG_ROOT="/links/rsync/"
RSYNC_PARAMS="-av"
CORRECTHOST="zinks-tp"
index="1 2 3 4 5 6"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1200
USE_SSH=false
CHECK_LASTRUN=false

Directories[1]="local/data/ssd_backup"
TargetDir[1]="local/backup/tpibm/local/data/ssd_backup"
MountTestFile[1]="/local/backup/doNotDelete"
Directories[2]="local/ssd_data/homes"
TargetDir[2]="local/data/ssd_backup/homes"
MountTestFile[2]="/local/data/doNotDelete"
Directories[3]="local/ssd_data/workdata"
TargetDir[3]="local/data/ssd_backup/workdata"
MountTestFile[3]="/local/data/doNotDelete"
Directories[4]="local/data/persdata"
TargetDir[4]="local/backup/tpibm/local/data/persdata"
MountTestFile[4]="/local/backup/doNotDelete"
Directories[5]="local/data/tmpdata"
TargetDir[5]="local/backup/tpibm/local/data/tmpdata"
MountTestFile[5]="/local/backup/doNotDelete"
Directories[6]="local/data/workdata_oldprojects"
TargetDir[6]="local/backup/tpibm/local/data/workdata_oldprojects"
MountTestFile[6]="/local/backup/doNotDelete"


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


#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="WDMyCloud1"
SSH_TGT_ROOT="root@${SSH_HOST}:/shares/Filer"
TGT_ROOT="/remote/WDMyCloud1/Filer"
LOG_ROOT="/links/rsync/"
RSYNC_PARAMS="-av --one-file-system --exclude-from /links/rsync/exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
CORRECTHOST="zinks-tp"
LASTRUN_FILENAME="$(basename ${0}).lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
index="1 2"


Directories[1]="links/ssd_backup"
TargetDir[1]="/zinks-tp/ssd_backup"
MountTestFile[1]=${TGT_ROOT}"/doNotDelete"
Directories[2]="links/persdata"
TargetDir[2]="/zinks-tp/persdata"
MountTestFile[2]=${TGT_ROOT}"/doNotDelete"

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

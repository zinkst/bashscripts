#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="WDMyCloud1"
SSH_TGT_ROOT="root@${SSH_HOST}:/shares/Filer/"
TGT_ROOT="/remote/WDMyCloud1/Filer"
LOG_ROOT="/links/sysbkp/rsync/"
RSYNC_PARAMS="-av -A --one-file-system --exclude-from /links/sysbkp/rsync_exclude.txt"
CORRECTHOST="kinder"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
index="1 2"

Directories[1]="local/data/kinder"
TargetDir[1]="kinder/kinder"
MountTestFile[1]="/remote/WDMyCloud1/Filer/doNotDelete"
Directories[2]="links/sysbkp"
TargetDir[2]="kinder/sysbkp"
MountTestFile[2]=${TGT_ROOT}"doNotDelete"


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


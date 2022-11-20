#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="WDMyCloud1"
SSH_TGT_ROOT="root@${SSH_HOST}:/shares/Filer"
TGT_ROOT="/remote/WDMyCloud1/Filer"
LOG_ROOT="/links/marion-pc/rsync/"
RSYNC_PARAMS="-av -A --one-file-system --exclude-from /links/marion-pc/rsync/exclude.txt"
CORRECTHOST="marion-pc"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
index="1"

Directories[1]="local/data/marion-pc"
TargetDir[1]="/marion-pc"
MountTestFile[1]="/remote/WDMyCloud1/Filer/doNotDelete"
Directories[2]="links/sysbkp"
TargetDir[2]="marion-pc/sysbkp"
MountTestFile[4]=${TGT_ROOT}"doNotDelete"


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


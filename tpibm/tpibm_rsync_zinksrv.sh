#!/bin/bash
# variables
SRC_ROOT="/"
#SRC_ROOT="/remote/tpibm/nfs4/data/"
TGT_ROOT="/remote/zinksrv/nfs4/data/"
LOG_ROOT="/links/rsync/"
RSYNC_PARAMS="-av --exclude-from /links/rsync/exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
CORRECTHOST="zinks-tp"
MOUNTTESTFILE=${TGT_ROOT}"doNotDelete"
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
index="1 2"

#if [ -f /etc/fedora-release ]
#then
#  CORRECTHOST=${CORRECTHOST}.boeblingen.de.ibm.com
#fi


Directories[1]="links/persdata/Stefan/privat"
TargetDir[1]="zinks-tp/persdata/Stefan/privat"
Directories[2]="links/workdata"
TargetDir[2]="zinks-tp/ssd_backup/workdata"




echo "index = ${index}"
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
    doRsyncWithTgtDir
else	
	doRsyncWithTgtDirAndMountTestFile
fi	
updateLastRunFile









# main routine
setLogfileName rsync
checkCorrectHost
rsyncParams $1
checkFSMounted "false"
if [ ${TARGETFSMOUNTED} == "true" ]
then
	echo "calling rsync"
	doRsyncWithTgtDir
fi
#date >> ${LOG_ROOT}/${LOGFILENAME}

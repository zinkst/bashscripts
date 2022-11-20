#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="qnap-ts130"
SSH_TGT_ROOT="root@${SSH_HOST}:/share/qnap-nas"
TGT_ROOT="/remote/qnap-nas/"
LOG_ROOT="/links/zinksrv/rsync_logs/"
RSYNC_PARAMS="-av -A --one-file-system --exclude-from /links/zinksrv/rsync_exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
CORRECTHOST="zinksrv"
MINS_SINCE_LASTRUN=-1500
CHECK_LASTRUN=false
USE_SSH=false
TRY_MOUNT_TGT="true"
REMOTEMOUNTPOINT=${TGT_ROOT}
index="1 2 3 4 5 6"
	
Directories[1]="local/data/zinksrv"
TargetDir[1]="zinksrv/data/zinksrv"
MountTestFile[1]="${TGT_ROOT}doNotDelete"
Directories[2]="local/data/zink-pc3"
TargetDir[2]="zinksrv/data/zink-pc3"
MountTestFile[2]="${TGT_ROOT}doNotDelete"
Directories[3]="local/data/zink-e595"
TargetDir[3]="/zinksrv/data/zink-e595"
MountTestFile[3]="${TGT_ROOT}doNotDelete"
Directories[4]="local/data/kinder2"
TargetDir[4]="zinksrv/data/kinder2"
MountTestFile[4]="${TGT_ROOT}doNotDelete"
Directories[5]="local/data/zink-w530"
TargetDir[5]="zinksrv/data/zink-w530"
MountTestFile[5]="${TGT_ROOT}doNotDelete"
Directories[6]="local/data/zink-ry4650g"
TargetDir[6]="zinksrv/data/zink-ry4650g"
MountTestFile[6]="${TGT_ROOT}doNotDelete"
Directories[7]="local/ntfsdata"
TargetDir[7]="same"
MountTestFile[7]="${TGT_ROOT}doNotDelete"
Directories[8]="local/ntfs_c"
TargetDir[8]="same"
MountTestFile[8]="${TGT_ROOT}doNotDelete"



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
if [ "${MOUNTEDBYBKPSCRIPT}" == "true" ]; then 
  echo "unmounting ${REMOTEMOUNTPOINT}"
  umount ${REMOTEMOUNTPOINT}
fi


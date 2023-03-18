#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="qnap-ts130"
#SSH_TGT_ROOT="root@${SSH_HOST}:/share/qnap-nas"
TGT_ROOT="/remote/qnap-ts130/data/"
LOG_ROOT="/links/zinksrv/rsync_logs/"
RSYNC_PARAMS="-av -A --one-file-system --exclude-from /links/zinksrv/rsync_exclude.txt"
LOGFILENAME=$(basename "${0}" .sh)
TEE_LOGS_TO_FILE=true
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
CORRECTHOST="zinksrv"
MINS_SINCE_LASTRUN=-1500
CHECK_LASTRUN=false
USE_SSH=false
TRY_MOUNT_TGT="true"
REMOTEMOUNTPOINT=${TGT_ROOT}
index="1 2 3 4 5 6 7" 
	
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

Directories[7]="local/data2"
TargetDir[7]="zinksrv/data2"
MountTestFile[7]="${TGT_ROOT}doNotDelete"

Directories[8]="local/ntfs_c"
TargetDir[8]="same"
MountTestFile[8]="${TGT_ROOT}doNotDelete"

Directories[9]="local/ntfsdata"
TargetDir[9]="same"
MountTestFile[9]="${TGT_ROOT}doNotDelete"

. /links/bin/bkp_functions.sh

usage() {
  echo "options are:"
  echo " -d: use --delete as additional rysnc parameter (deletes on target)"
  echo " -n: use -n as additional rysnc parameter (does only a dry-run do not actually copy files)"
  echo " -s: use ssh based rsync as target"
  echo " -c: check when the script was last run and exit if it was within the last ${MINS_SINCE_LASTRUN} minutes"
	echo " -t: toggle power of qnap nas"
	printParams
	exit -1
}  

function checkInputParams() {
	while getopts "tdnsc" OPTNAME
	do
		case "${OPTNAME}" in
			t) export QNAP_TOGGLE_POWER=false;;
			c ) CHECK_LASTRUN=true;;
			d ) RSYNC_DELETE=true;;
			n ) RSYNC_PARAMS="${RSYNC_PARAMS} -n";;
			s ) TGT_ROOT=${SSH_TGT_ROOT}
				USE_SSH=true
				;;	
			*)
				usage 
		esac
	done
 	echo "@ = ${@}"
	shift $((OPTIND-1))
	if  [ $# -gt 0 ]
	then
		index=$1
	fi

}

function printParams() {
	echo "TGT_ROOT = ${TGT_ROOT}"
	echo "RSYNC_PARAMS=${RSYNC_PARAMS}"
	echo "USE_SSH = ${USE_SSH}"
	echo "CHECK_LASTRUN = ${CHECK_LASTRUN}"
	echo "QNAP_TOGGLE_POWER=${QNAP_TOGGLE_POWER}"
	echo "index = ${index}"
}

# main routine
QNAP_TOGGLE_POWER=true
checkInputParams $@
printParams
if [ ${QNAP_TOGGLE_POWER} == true ]; then
	powerQnap.sh
	echo "wait 10 minutes until qnap is started"
	sleep 720 
fi

setLogfileName ${LOGFILENAME}
checkCorrectHost
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

if [ checkToggleQnap == true ]; then
	powerQnap.sh -s
fi


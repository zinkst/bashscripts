#!/bin/bash
# set -euo pipefail
# variables
export SRC_ROOT="/"
export TGT_ROOT="/remote/qnap-ts130/data_smb"
export QNAP_TOGGLE_POWER=true
export RESTIC_PATH="zinksrv_restic"
export RESTIC_REPOSITORY="${TGT_ROOT}/${RESTIC_PATH}"
export RESTIC_PASSWORD_FILE=/links/etc/restic/restic_pwd_file
export MOUNTED_BY_SCRIPT=false
LOGFILENAME=$(basename "${0}" .sh)
export LOG_ROOT="/links/Not4Backup/BackupLogs/${LOGFILENAME}/"
CORRECTHOST="zinksrv"
export ETHERWAKE_INTERFACE=enp4s0
index="1 2 3 4 5 6 7" 

Directories[1]="local/data/zinksrv"
Directories[2]="local/data/zink-e595"
Directories[3]="local/data/kinder2"	  # Valentin 	
Directories[4]="local/data/zink-pc4"  # Henry
Directories[5]="local/data2"
Directories[6]="local/data/zink-pc3"  # Laptop L530
Directories[7]="local/data/zink-w530" # Georg
Directories[8]="local/ntfs_c"
Directories[9]="local/ntfsdata"


source /links/bin/lib/bkp_functions.sh
source /links/bin/lib/resticFunctions.sh

function checkResticInputParams() {
	while getopts "t" OPTNAME
	do
		case "${OPTNAME}" in
			t) export QNAP_TOGGLE_POWER=false;;
			*)
				usage 
		esac
	done
 	echo "@ = ${@}"
	shift $((OPTIND-1))
	if  [ $# -gt 0 ]
	then
		index="$@"
	fi

}

# main routine
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
checkResticInputParams $@
printResticParams

mkdir -p "${LOG_ROOT}"
checkCorrectHost
prepareRsyncConfig "${LOGFILENAME}"
mkdir -p "${LOG_ROOT}"
logrotate -f /links/etc/logrotate.d/${LOGFILENAME}_logs
echo LogFileName: ${LOG_ROOT}${LOGFILENAME}
LOGFILENAME=${LOGFILENAME}.log
mountQNAP
#initializeBackupStore
doResticWithTgtDirAndMountTest
ShowResticSnapshots
doResticForgetKeepOnlyLastNSnapshots 12
df -h ${TGT_ROOT} | tee -a ${LOG_ROOT}${LOGFILENAME}
unmountQNAP
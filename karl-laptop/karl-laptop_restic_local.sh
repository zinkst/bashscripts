#!/bin/bash
# variables
export SRC_ROOT="/"
export TGT_ROOT="/local/backup"
export RESTIC_PATH="/karl-laptop/restic_local"
export RESTIC_REPOSITORY="${TGT_ROOT}/${RESTIC_PATH}"
export RESTIC_PASSWORD_FILE="/root/restic/passwd_file"
LOGFILENAME=$(basename "${0}" .sh)
export LOG_ROOT="${TGT_ROOT}/BackupLogs/${LOGFILENAME}/"
CORRECTHOST="karl-laptop"
index="1"

Directories[1]="home"

source /links/bin/lib/bkp_functions.sh
source /links/bin/lib/resticFunctions.sh

# main
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
mkdir -p "${LOG_ROOT}"
# setLogfileName ${LOGFILENAME}
checkCorrectHost
prepareRsyncConfig "${LOGFILENAME}"
logrotate -f /links/etc/logrotate.d/${LOGFILENAME}_logs
LOGFILENAME=${LOGFILENAME}.log
echo LogFileName: ${LOG_ROOT}${LOGFILENAME}

# echo "intializing Backup store" && initializeBackupStore
echo "starting  backup" && doResticWithTgtDir
ShowResticSnapshots


#!/bin/bash
# variables
SRC_ROOT="/"
SSH_HOST="zinksrv"
TGT_ROOT="/remote/zinksrv/nfs4/"
LOG_ROOT="/local/backup/BackupLogs/rsync/"
mkdir -p ${LOG_ROOT}
RSYNC_PARAMS="-av --one-file-system --exclude-from /links/sysbkp/rsync/rsync_exclude.txt"
# RSYNC_PARAMS="-av --one-file-system"
CORRECTHOST="karl-laptop"
# LOGFILENAME=$(basename "${0}" .sh)
LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
MINS_SINCE_LASTRUN=-1500
USE_SSH=false
CHECK_LASTRUN=false
REMOTEMOUNTPOINT=${TGT_ROOT}
TRY_MOUNT_TGT="true"
index="1 2"

Directories[1]="home/"
TargetDir[1]="data/Other-Systems/Karl-Laptop/home"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
Directories[2]="local/backup/karl-laptop/sysbkp"
TargetDir[2]="data/Other-Systems/Karl-Laptop/sysbkp"
MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"



. /links/bin/lib/bkp_functions.sh

# main routine
setLogfileName ${LOGFILENAME}
checkCorrectHost
rsyncBkpParamCheck $@
doRsyncWithTgtDirAndMountTestFile
#cmd="rsync -av /local/vhds/vhds/win10.vhd ${TGT_ROOT}data/Other-Systems/Karl-Laptop/sysbkp/$(hostname)_$(date +'%Y%m%d')_win10.vhd"
#echo $cmd
#eval $cmd
#cmd="rsync -av /links/sysbkp/karl-laptop_Fedora-$(lsb_release -s -r)*.tgz ${TGT_ROOT}data/Other-Systems/Karl-Laptop/sysbkp/"
#echo $cmd
#eval $cmd

umount ${REMOTEMOUNTPOINT}

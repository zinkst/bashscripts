#!/bin/bash

function installRestic {
	dnf -y install rclone rclone-browser restic
}

function initializeBackupStore {
	restic init
	# zinksrv usb-2
	# created restic repository ba8a87ebb8 at /run/media/BKP_ZINK_USB_2-part1/zinksrv_restic
}


ShowResticSnapshots () 
{
  if mountpoint -q "${TGT_ROOT}"; then
	cmd="restic snapshots"
	echo "$cmd"
	eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
  else
    echo "${TGT_ROOT} not mounted skipping" | tee -a ${LOG_ROOT}${LOGFILENAME}
  fi
}

function powerOnTasmotaPlug() {
    POWER_STATE=$(curl -s http://${1}/cm?cmnd=${2} | jq '.POWER2')
    if [ "${POWER_STATE}" != '"ON"' ]; then
        echo "Power On ${1} ${2}"
        curl -s http://${1}/cm?cmnd=${2}%20On && echo
        echo "waiting 30 seconds" && sleep 30
    else
        echo "${1} ${2} already powered on"
    fi
}  

function doResticWithTgtDir () 
{
  	for ind in $index
	do
		tag=$(basename "${SRC_ROOT}${Directories[ind]}")
        cmd="restic backup --exclude-caches --no-cache --verbose=1 --tag $tag \"${SRC_ROOT}${Directories[ind]}/\""
		echo "$cmd"
		eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
    done		
}

function doResticForgetKeepOnlyLastNSnapshots() 
{
  	numOfSnapshotsToKeep=${1}
	for ind in $index
	do
		tag=$(basename "${SRC_ROOT}${Directories[ind]}")
        cmd="restic forget --keep-last ${numOfSnapshotsToKeep} --prune --verbose=2 --tag $tag"  
		echo "$cmd"
		eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
    done		
}

function doResticWithTgtDirAndMountTest () 
{
  if mountpoint -q "${TGT_ROOT}"; then
  	doResticWithTgtDir
  else
    echo "${TGT_ROOT} not mounted skipping" | tee -a ${LOG_ROOT}${LOGFILENAME}
  fi
}

function doResticFamilienVideos ()
{
  export FAMILIENVIDEOS_ROOT_PATH="${1:-local/data/zinksrv/FamilienVideos}"
  export NUMBER_OF_YEARS_TO_BACKUP="${2:-10}"
  export numOfSnapshotsToKeep="${3:-2}"
  echo NUMBER_OF_YEARS_TO_BACKUP=${NUMBER_OF_YEARS_TO_BACKUP}
  export THIS_YEAR=$(date +'%Y')
  export FIRST_YEAR="$(($THIS_YEAR-$NUMBER_OF_YEARS_TO_BACKUP+1))" 
  echo THIS_YEAR=${THIS_YEAR} FIRST_YEAR=${FIRST_YEAR}
  SUBFOLDERS=("Familie-Zink-Videos" "Favoriten-Familie-Zink-Videos" )
  for subFolder in "${SUBFOLDERS[@]}"; do
    for (( curYear = ${FIRST_YEAR}; curYear <= ${THIS_YEAR}; curYear++ )); do
	  BACKUP_PATH="${SRC_ROOT}${FAMILIENVIDEOS_ROOT_PATH}/${subFolder}/${curYear}"
	  printf 'Backing up %s\n' "${BACKUP_PATH}"
	  tag="${curYear}_${subFolder}"
	  cmd="restic backup --exclude-caches --no-cache --verbose=1 --tag $tag \"${BACKUP_PATH}\""
	  # echo "$cmd"
	  eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
	  cmd="restic forget --keep-last ${numOfSnapshotsToKeep} --prune --verbose=2 --tag $tag"  
	  # echo "$cmd"
	  eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
	done
  done	
}


# function restoreRestic () {
# 	RESTORE_PATH="${1}"
#	echo "Mounting ${RESORE_PATH} to /run/media/restic-restore"
#   mkdir -p /run/media/restic-restore
# 	tag=$(basename "${SRC_ROOT}${Directories[ind]}")
# 	cmd="restic restore latest --path \"${SRC_ROOT}${Directories[ind]}/\"" --target /run/media/restic-restore
# 	cmd="restic restore latest --path ${RESTORE_PATH} --target /run/media/restic-restore
# 	echo "$cmd"
# 	#eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
# }

testServerPing ()
{
    ping -q -c 5 ${1}
    return $?
}

function mountRestic (){
	ind=${1}
	mkdir -p /run/media/restic-mount
	tag=$(basename "${SRC_ROOT}${Directories[ind]}")
	cmd="restic mount --allow-other --tag ${tag} /run/media/restic-mount"
	echo "$cmd"
	#eval "$cmd" | tee -a ${LOG_ROOT}${LOGFILENAME}
}


function printResticParams() {
	echo "TGT_ROOT = ${TGT_ROOT}"
	echo "QNAP_TOGGLE_POWER=${QNAP_TOGGLE_POWER}"
	echo "index = ${index}"
}

function mountQNAP() {
	if mountpoint -q "${TGT_ROOT}" ; then
      	echo "${TGT_ROOT} already mounted"
	else
		if testServerPing qnap-ts130; then 
			echo "qnap-ts130 is pingable"
		else
			if [ ${QNAP_TOGGLE_POWER} == true ]; then
				/links/bin/powerQnap.sh -i ${ETHERWAKE_INTERFACE}
				echo "$(date +'%y%m%d_%H%M%S') wait 10 minutes until qnap is started"
				sleep 720 
			fi
		fi	
		echo "$(date +'%y%m%d_%H%M%S') mounting ${TGT_ROOT}"
		cmd="mount -v ${TGT_ROOT}"
		echo "$cmd"
		eval "$cmd"
		MOUNTED_BY_SCRIPT=true
	fi
}

function unmountQNAP() {
	if [ "${MOUNTED_BY_SCRIPT}" == "true" ]; then 
		echo "unmounting ${TGT_ROOT}"
		umount ${TGT_ROOT}
		sleep 30
		if [ ${QNAP_TOGGLE_POWER} == true ]; then
			/links/bin/powerQnap.sh -s
		fi
	fi
}

setLogfileName ()
{
  if [ ! -z ${1} ]; then
    DATETIMESTRING=$(date +'%y%m%d_%H%M%S')
    LOGFILENAME="${DATETIMESTRING}_${1}.log"
  fi  
  echo ${LOGFILENAME} 
}

function checkCorrectHost ()
{
  HOSTNAME=`hostname | awk ' BEGIN { FS="." }; {print $1}'`
  echo "CORRECTHOST = ${CORRECTHOST}"
  echo "HOSTNAME = ${HOSTNAME}"
  if [ ${CORRECTHOST} = ${HOSTNAME} ] 
  then
    echo "we are on the correct host, we can continue"
  else
    echo "Please start this command only from ${CORRECTHOST}"
    exit
  fi;
}

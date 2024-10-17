#!/bin/bash

setDateTimeString ()
{
  #tag=$(date +'%d')
  #monat=$(date +'%m')
  #jahr=$(date +'%y')
  #hour=$(date +'%H')
  #minute=$(date +'%M')
  #second=$(date +'%S')
  #DATETIMESTRING="${jahr}${monat}${tag}_${hour}${minute}${second}"
  DATETIMESTRING=$(date +'%y%m%d_%H%M%S')
}

setLogfileName ()
{
  if [ ! -z ${1} ]; then
    setDateTimeString
    LOGFILENAME="${DATETIMESTRING}_${1}.log"
  fi  
  echo ${LOGFILENAME} 
}

checkFSMounted ()
# $1 tryToMount
# $2 MOUNTTESTFILE
{
  if [ ! -z $2 ] 
  then
    MOUNTTESTFILE=$2
  fi
  echo "MOUNTTESTFILE = ${MOUNTTESTFILE}"
  TARGETFSMOUNTED="false"
  if [ ! -z $MOUNTEDBYBKPSCRIPT ] 
  then
    MOUNTEDBYBKPSCRIPT="false"
  fi  
  if [ -f ${MOUNTTESTFILE} ]; then
    echo ${MOUNTTESTFILE} "exists we can continue" | tee -a ${LOG_ROOT}${LOGFILENAME}
    TARGETFSMOUNTED="true"
  else
    if [ $1 == "false" -a ${TARGETFSMOUNTED} == "false" ]; then
      echo ${MOUNTTESTFILE} "does not exist, please mount first"
    fi	
    if [ $1 == "true" ]; then
    	echo ${MOUNTTESTFILE} "does not exist, trying to mount remote filesystem first" | tee -a ${LOG_ROOT}${LOGFILENAME}
    	mount ${REMOTEMOUNTPOINT} | tee -a ${LOG_ROOT}${LOGFILENAME}
      if [ -f ${MOUNTTESTFILE} ]; then
        MOUNTEDBYBKPSCRIPT="true"
        echo ${MOUNTTESTFILE} "exists we can continue" | tee -a ${LOG_ROOT}${LOGFILENAME}
        TARGETFSMOUNTED="true"
      else	
        TARGETFSMOUNTED="false"
      fi
    fi		
  fi;
}

doRsyncWithParams () 
{
    echo "starting rsync of ${1} with  ${2}" | tee -a ${LOG_ROOT}${LOGFILENAME}
    date >> ${LOG_ROOT}${LOGFILENAME}
    echo "rsync ${RSYNC_PARAMS_USED} ${1}/ ${2}" | tee -a ${LOG_ROOT}${LOGFILENAME}
    rsync ${RSYNC_PARAMS_USED} ${1}/ ${2} | tee -a ${LOG_ROOT}${LOGFILENAME}
    date >> ${LOG_ROOT}${LOGFILENAME}
}



#doRsync () 
#{
  #for ind in $index
  #do
    #echo "starting rsync of ${Directories[ind]}" | tee -a ${LOG_ROOT}${LOGFILENAME}
    #date >> ${LOG_ROOT}${LOGFILENAME}
    #echo "rsync ${RSYNC_PARAMS} ${SRC_ROOT}${Directories[ind]}/ ${TGT_ROOT}${Directories[ind]}" | tee -a ${LOG_ROOT}${LOGFILENAME}
    #rsync ${RSYNC_PARAMS} ${SRC_ROOT}${Directories[ind]}/ ${TGT_ROOT}${Directories[ind]} | tee -a ${LOG_ROOT}${LOGFILENAME}
    #date >> ${LOG_ROOT}${LOGFILENAME}
  #done;
#}

doRsyncWithTgtDir () 
{
  for ind in $index
  do
    if [ -n "${TargetDir[ind]}" ]
    then
		if [ ${TargetDir[ind]} == "same" ]
		then
			TargetDir[ind]=${Directories[ind]}
		fi
		echo "AllowDelete[$ind]=${AllowDelete[ind]}"
		echo "RSYNC_DELETE=${RSYNC_DELETE}"
		if [[ ${RSYNC_DELETE} == "true"  &&  ! ${AllowDelete[ind]} == "false"  ]] 
		then
		  echo "adding delete parameter to RSYNC_PARAMS"
		  RSYNC_PARAMS_USED="${RSYNC_PARAMS} --delete"
		else
		  echo "Do not add delete parameter to RSYNC_PARAMS"
		  RSYNC_PARAMS_USED=${RSYNC_PARAMS}	
		fi 	  		
		echo RSYNC_PARAMS_USED=${RSYNC_PARAMS_USED}
		echo "starting rsync of ${Directories[ind]}" | tee -a ${LOG_ROOT}${LOGFILENAME}
		date >> ${LOG_ROOT}${LOGFILENAME}
		echo "rsync ${RSYNC_PARAMS_USED} ${SRC_ROOT}${Directories[ind]}/ ${TGT_ROOT}${TargetDir[ind]}" | tee -a ${LOG_ROOT}${LOGFILENAME}
		rsync ${RSYNC_PARAMS_USED} ${SRC_ROOT}${Directories[ind]}/ ${TGT_ROOT}${TargetDir[ind]} | tee -a ${LOG_ROOT}${LOGFILENAME}
		date >> ${LOG_ROOT}${LOGFILENAME}
    else
		echo "no target defined for index $ind"
	fi	
  done;
}

doRsyncWithTgtDirAndMountTestFile () 
{ 
  ${TRY_MOUNT_TGT:+"false"}
  echo "doRsyncWithTgtDirAndMountTestFile called"
  for ind in $index
  do
    if [ -n "${TargetDir[ind]}" ]
    then
		echo "MountTestFile[$ind] = " ${MountTestFile[ind]}
		if test -z ${MountTestFile[ind]} 
		then
		  echo "calling checkFSMounted ${TRY_MOUNT_TGT} "
		  checkFSMounted ${TRY_MOUNT_TGT} 
		else
		  echo "calling checkFSMounted ${TRY_MOUNT_TGT} ${MountTestFile[ind]} "
		  checkFSMounted ${TRY_MOUNT_TGT} ${MountTestFile[ind]} 
		fi
		if [ ${TARGETFSMOUNTED} == "true" ]
		then
		  if [ "${TargetDir[ind]}" == "same" ]
		  then
			 TargetDir[ind]=${Directories[ind]}
		  fi
		  echo "AllowDelete[$ind]=${AllowDelete[ind]}"
		  echo "RSYNC_DELETE=${RSYNC_DELETE}"
		  if [[ "${RSYNC_DELETE}" == "true"  &&  ! ${AllowDelete[ind]} == "false"  ]] 
		  then
			  echo "adding delete parameter to RSYNC_PARAMS"
			  RSYNC_PARAMS_USED="${RSYNC_PARAMS} --delete"
		  else
			  echo "Do not add delete parameter to RSYNC_PARAMS"
			  RSYNC_PARAMS_USED=${RSYNC_PARAMS}	
		  fi 	  		
		  echo RSYNC_PARAMS_USED=${RSYNC_PARAMS_USED}
		  echo "starting rsync of ${Directories[ind]}" | tee -a ${LOG_ROOT}${LOGFILENAME}
		  date >> "${LOG_ROOT}${LOGFILENAME}"
		  if [ "${TEE_LOGS_TO_FILE}" == "false" ]; then
		  	echo "rsync ${RSYNC_PARAMS_USED} \"${SRC_ROOT}${Directories[ind]}/\" \"${TGT_ROOT}${TargetDir[ind]}/\""
		  	rsync ${RSYNC_PARAMS_USED} "${SRC_ROOT}${Directories[ind]}/" "${TGT_ROOT}${TargetDir[ind]}/"
		  else
		  	echo "rsync ${RSYNC_PARAMS_USED} \"${SRC_ROOT}${Directories[ind]}/\" \"${TGT_ROOT}${TargetDir[ind]}/\" " | tee -a "${LOG_ROOT}${LOGFILENAME}" 
		  	rsync ${RSYNC_PARAMS_USED} "${SRC_ROOT}${Directories[ind]}/" "${TGT_ROOT}${TargetDir[ind]}/" | tee -a "${LOG_ROOT}${LOGFILENAME}"
		  fi	
		  date >> "${LOG_ROOT}${LOGFILENAME}"
		fi
	 else
		echo "no target defined for index $ind"
	 fi		
  done;
}

rsyncBkpParamCheck ()
{
	while getopts "dnsc" Option
	do
		case $Option in
			c ) CHECK_LASTRUN=true;;
			#d ) RSYNC_PARAMS="${RSYNC_PARAMS} --delete";;
			d ) RSYNC_DELETE=true;;
			n ) RSYNC_PARAMS="${RSYNC_PARAMS} -n";;
			s ) TGT_ROOT=${SSH_TGT_ROOT}
				USE_SSH=true
				;;	
		    * ) rsyncBkpParamCheckUsage
				echo " exiting due to invalid option  ${@} " #:$OPTIND:1}"
		        exit  
				;;		  
		esac
	done

	echo "@ = ${@}"
	shift $((OPTIND-1))
	if  [ $# -gt 0 ]
	then
		index=$@
	fi

	echo "TGT_ROOT = ${TGT_ROOT}"
	echo "RSYNC_PARAMS=${RSYNC_PARAMS}"
	echo "USE_SSH = ${USE_SSH}"
	echo "CHECK_LASTRUN = ${CHECK_LASTRUN}"
	echo "index = ${index}"
}

rsyncBkpParamCheckUsage ()
{
  echo "options are:"
  echo " -d: use --delete as additional rysnc parameter (deletes on target)"
  echo " -n: use -n as additional rysnc parameter (does only a dry-run do not actually copy files)"
  echo " -s: use ssh based rsync as target"
  echo " -c: check when the script was last run and exit if it was within the last ${MINS_SINCE_LASTRUN} minutes"
}	


checkCorrectHost ()
{
  #if [ -f /etc/fedora-release ]
  #then
	# returns localhost with hostname -s
	#HOSTNAME=`hostname`
  #else
	#HOSTNAME=`hostname`
  #fi
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

#test if server is reachable
testServerPing ()
{
    ping -q -c 5 ${SERVERIP}
    if [ $? -ne 0 ]
    then
      SERVERPINGABLE="false"
    else
      SERVERPINGABLE="true"
    fi
}    

setExtension()
{
    EXTENSION="tar" 
    if [[ ${TarOpts[$1]} == *z* ]]
    then 
        EXTENSION="tgz"
    fi
    echo "EXTENSION = " ${EXTENSION}     
}

createTars()
{
    setDateTimeString
    for crtTarsIdx in $index
    do
        setExtension crtTarsIdx
        LOGFILENAME=${TargetNames[crtTarsIdx]}_${EXTENSION}.log
        echo "rm ${LOG_ROOT}${LOGFILENAME}" | tee -a ${LOG_ROOT}${LOGFILENAME}
        rm ${LOG_ROOT}${LOGFILENAME}
        echo "rm ${BACKUPDIR}/${TargetNames[crtTarsIdx]}.${EXTENSION}" | tee -a ${LOG_ROOT}${LOGFILENAME}
        rm ${BACKUPDIR}/${TargetNames[crtTarsIdx]}.${EXTENSION} | tee -a ${LOG_ROOT}${LOGFILENAME}
        echo "starting creation of ${BACKUPDIR}/${TargetNames[crtTarsIdx]}.${EXTENSION} at" | tee -a ${LOG_ROOT}${LOGFILENAME}
        date | tee -a ${LOG_ROOT}${LOGFILENAME}
        echo "tar ${TarOpts[crtTarsIdx]} ${BACKUPDIR}/${TargetNames[crtTarsIdx]}.${EXTENSION} --directory ${Directories[crtTarsIdx]} --one-file-system ${Directories[crtTarsIdx]}*"
        tar ${TarOpts[crtTarsIdx]} ${BACKUPDIR}/${TargetNames[crtTarsIdx]}.${EXTENSION} --directory ${Directories[crtTarsIdx]} --one-file-system . | tee -a ${LOG_ROOT}${LOGFILENAME}
        echo "finished creation of ${BACKUPDIR}/${TargetNames[crtTarsIdx]}.${EXTENSION} at" | tee -a ${LOG_ROOT}${LOGFILENAME}
        date | tee -a ${LOG_ROOT}${LOGFILENAME}
    done    
}




copyTarFilesToDestination() 
{
    for cpTarsIdx in $index
    do
    	echo "LOGFILENAME = ${LOG_ROOT}${LOGFILENAME}" | tee -a ${LOG_ROOT}${LOGFILENAME}
        setExtension cpTarsIdx
        echo "EXTENSION =  ${EXTENSION}" | tee -a ${LOG_ROOT}${LOGFILENAME}
        echo -n "starting backup of ${Direcrories[cpTarsIdx]}" | tee -a ${LOG_ROOT}${LOGFILENAME}
        date | tee -a ${LOG_ROOT}${LOGFILENAME}
        if [ -t ${DESTINATIONBACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} ]
        then 
            echo "rm ${DESTINATIONBACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION}" | tee -a ${LOG_ROOT}${LOGFILENAME}
            rm ${DESTINATIONBACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} | tee -a ${LOG_ROOT}${LOGFILENAME}
        fi
        echo -n "starting copy of ${BACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} to ${DESTINATIONBACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} at" | tee -a ${LOG_ROOT}${LOGFILENAME}
        date | tee -a ${LOG_ROOT}${LOGFILENAME}
        echo "cp ${BACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} ${DESTINATIONBACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION}" | tee -a ${LOG_ROOT}${LOGFILENAME}
        (cp -v ${BACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} ${DESTINATIONBACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} | tee -a ${LOG_ROOT}${LOGFILENAME} )  3>&1 1>&2 2>&3 | tee -a ${LOG_ROOT}${LOGFILENAME}
        echo -n "finished copy of ${BACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} to ${DESTINATIONBACKUPDIR}/${TargetNames[cpTarsIdx]}.${EXTENSION} at" | tee -a ${LOG_ROOT}${LOGFILENAME}
        date | tee -a ${LOG_ROOT}${LOGFILENAME}
    done
}



# Are we running in a VM?
vmware_inVM() 
{
	vmdb_answer_SBINDIR="/usr/sbin"
	# echo $vmdb_answer_SBINDIR/vmware-checkvm
  "$vmdb_answer_SBINDIR"/vmware-checkvm >/dev/null 2>&1
}

determineDistribution ()
{
  DISTRIBUTOR=`lsb_release -i | awk ' BEGIN { FS=":" }; {print $2}'`
  #echo ${DISTRIBUTOR}
  RELEASE=`lsb_release -r | awk ' BEGIN { FS=":" }; {print $2}'`
  #echo ${RELEASE}
  ARCHITECTURE=`uname -m`
  #echo ${ARCHITECTURE}
  DISTRIBUTION=${DISTRIBUTOR}-${RELEASE}-${ARCHITECTURE}
  DISTRIBUTION=`echo ${DISTRIBUTION} | sed -e "s/ //g"`
  echo "DISTRIBUTION= ${DISTRIBUTION}"
}

java_env ()
{
  echo ${1}
  if [ ! -z ${1} ] 
  then 
    if [ "open" = ${1} ]
    then
      if [ ${DISTRIBUTOR} = "Ubuntu" ]
      then
        JAVA_HOME="/usr/lib/jvm/java-6-openjdk/jre/"
      else
         if [ `uname -m` = "x86_64" ]
         then
            JAVA_HOME="/usr/lib/jvm/jre-openjdk/"
         else
            JAVA_HOME="/usr/lib/jvm/jre-openjdk/"   
         fi   
      fi
    fi  	
  else
	  if [ ${DISTRIBUTOR} = "Ubuntu" ]
	  then
		  JAVA_HOME="/usr/lib/j2sdk1.6-ibm/"
	  else
       if [ `uname -m` = "x86_64" ]
       then
          JAVA_HOME="/usr/lib/jvm/jre-1.7.0-ibm.x86_64/"
       else
          JAVA_HOME="/usr/lib/jvm/jre-1.7.0-ibm/"   
       fi   
	  fi	
  fi
  echo JAVA_HOME=${JAVA_HOME}
  JAVA_PROGRAM_DIR=${JAVA_HOME}bin/ 
}

determineSystemByHostname ()
{
	HOSTNAME=`hostname -s`
	SYSTEM=${HOSTNAME}
	echo "HOSTNAME = ${HOSTNAME}"
	if [ ${HOSTNAME} = "marion-pc" -o ${HOSTNAME} = "marion-pc.fritz.box" ] 
	then
	  SYSTEM="marion"
	elif [ ${HOSTNAME} = "zinks-tp.boeblingen.de.ibm.com" -o ${HOSTNAME} = "zinks-tp" -o ${HOSTNAME} = "stefan" -o ${HOSTNAME} = "stefan.zink.sulz.de" ] 
	then 
	  SYSTEM="tpibm"
	elif [ ${HOSTNAME} = "zinksrv"  -o  ${HOSTNAME} = "zinksrv.zink.sulz.de" ]
	then 
	  SYSTEM="zinksrv"
	fi;

}

moveFile ()
{
  if [ -e ${1} ] 
  then
    #echo -e "${1} exists moving to -> ${2}\n"
    MVCMD="mv ${1} ${2}"
    if [ ${TESTFLAG} == "false" ]
    then
        echo ${MVCMD}
        `${MVCMD}`
    else
        echo -e "TestFlag set: ${MVCMD} not executed"
    fi
  fi     
}

moveFileNoTargetOverwrite ()
{
	if [ -e ${2} ] 
	then
		echo -e "${1} exists and ${2} does exist, no overwrite of target is done"
	else
		moveFile ${1} ${2}
	fi	
}


linkFile ()
{
  LINKCMD="ln -sf ${1} ${2}"
  if [ ${TESTFLAG} == "false" ]
  then
    echo ${LINKCMD}
    `${LINKCMD}`
  else
    echo -e "TestFlag set: ${LINKCMD} not executed"
  fi
}

copyFile ()
{
  #echo "-------------- ${FILESRC[crtIdx]} ---------------"   
  #COPYCMD="cp -prv ${SAMETIME_SRC_FOLDER}/${FILESRC[crtIdx]} ${FILETGT[crtIdx]}"
  COPYCMD="cp -prv ${1} ${2}"
  if [ ${TESTFLAG} == "false" ]
  then
    echo ${COPYCMD}
     ${COPYCMD}
  else
    echo -e "TestFlag set: ${COPYCMD} not executed"
  fi
}

checkLastRun ()
{
	echo "checkLastRun with file ${LASTRUN_FILENAME} and exit if it was run within the last ${MINS_SINCE_LASTRUN} minutes"
	if [ -f ${LOG_ROOT}${LASTRUN_FILENAME} ]
    then 
		LAST_MODIFIED=`/bin/stat -c %y ${LOG_ROOT}${LASTRUN_FILENAME}  | cut -f1 -d '.'`
		HOUR_SINCE=$(((`/bin/date -d "$LAST_MODIFIED" +%s` - `/bin/date +%s`)/3600))
		if [[ -z $(/bin/find ${LOG_ROOT} -cmin ${MINS_SINCE_LASTRUN} -name ${LASTRUN_FILENAME}) ]];
		then
		  echo "${LASTRUN_FILENAME} file found older than 24 hours: $LAST_MODIFIED ($HOUR_SINCE hours ago)"
		  echo $(ls -l ${LOG_ROOT}${LASTRUN_FILENAME})
		else
		  echo "${LASTRUN_FILENAME} file not found 24 hours ago exiting => so it must be newer => exiting"
		  echo $(ls -l ${LOG_ROOT}${LASTRUN_FILENAME})
		  exit
		fi
	else
	    echo "${LOG_ROOT}${LASTRUN_FILENAME} not found continuing"
	fi	
}

updateLastRunFile ()
{
  if [ -f ${LOG_ROOT}${LASTRUN_FILENAME} ]
  then
	 rm -f ${LOG_ROOT}${LASTRUN_FILENAME}
  fi
  touch ${LOG_ROOT}${LASTRUN_FILENAME} 
}

function processRsyncBackup() {
  # variables
  export SRC_ROOT=${SRC_ROOT:-"/"}
  export TGT_ROOT=${TGT_ROOT:-"/remote/zinksrv/nfs4/"}
  LOGFILENAME=$(basename "${0}" .sh)
  export LOG_ROOT="/links/Not4Backup/BackupLogs/${LOGFILENAME}/"
  export RSYNC_PARAMS=${RSYNC_PARAMS:-"-av -A --one-file-system --exclude-from /links/etc/my-etc/rsync/rsync_exclude.txt"}
  LASTRUN_FILENAME="${LOGFILENAME}.lastrun"
  export MINS_SINCE_LASTRUN=${MINS_SINCE_LASTRUN:-"-1500"}
  export CHECK_LASTRUN=${CHECK_LASTRUN:-false}
  REMOTEMOUNTPOINT=${TGT_ROOT}
  export TRY_MOUNT_TGT=${TRY_MOUNT_TGT:-"true"}

  prepareBackupLogs
  prepareRsyncConfig "${LOGFILENAME}"
  mkdir -p "${LOG_ROOT}"
  logrotate -f /links/etc/logrotate.d/${LOGFILENAME}_logs
  LOGFILENAME=${LOGFILENAME}.log
  echo LOG_PATH=${LOG_ROOT}${LOGFILENAME}
  checkCorrectHost
  rsyncBkpParamCheck $@
  if [ ${CHECK_LASTRUN} == true ]
  then
    checkLastRun
  fi
  doRsyncWithTgtDirAndMountTestFile
  updateLastRunFile
  umount ${REMOTEMOUNTPOINT}
}

function prepareBackupLogs () {
  BACKUP_LOGS_DIR="/local/data/Not4Backup/BackupLogs"
  if [ ! -d "${BACKUP_LOGS_DIR}" ]; then
    echo "${BACKUP_LOGS_DIR}" does not exist creating it
    mkdir -p "${BACKUP_LOGS_DIR}"
  fi
  if [[ ! -L "/links/Not4Backup" ]]; then
    echo "symbolic link /links/Not4Backup needs to be created"
    ln -sf ${BACKUP_LOGS_DIR} /links/Not4Backup
  fi  
}

function prepareRsyncConfig() {
  if [ -f "/links/etc" ]; then
		echo "symbolic link /links/etc exists - no setup needed"
    return
  else
    ETC_DIR="/local/data/$(hostname -s)/etc"
    if [ ! -d "${ETC_DIR}" ]; then
      echo "${ETC_DIR}" does not exist creating it
      mkdir -p "${ETC_DIR}"
    fi
    if [ ! -L "/links/etc" ]; then
      ln -sf ${ETC_DIR} /links/etc
    fi  
  fi
  LOGGER=${1}
  mkdir -p "${ETC_DIR}/logrotate.d"

  cat   <<EOF > "${ETC_DIR}/logrotate.d/${LOGGER}_logs"
/links/Not4Backup/BackupLogs/${LOGGER}/${LOGGER}.log
{
    rotate 4
    missingok
    notifempty
    compress
}
EOF
chmod 600 ${ETC_DIR}/logrotate.d/${LOGGER}_logs

  mkdir -p "${ETC_DIR}/my-etc/rsync"
  cat   <<EOF > "${ETC_DIR}/my-etc/rsync/rsync_exclude.txt"
Backup
lost+found
vms/*.vhd
vms/VB/W7-prof-32bit/Windows7.vdi
vms/VB/w7-ultimate-64/W7-ultimate-64.vhd
vms/VB/Win81/win8pro.vhd
vms/VB/Win81-zinksrv-vm/win81_pro_zinksrv.vhd
vms/VB/Fedora/Fedora.vdi
vms/*/Snapshots/*
*XP_Pro_de.vmdk
*.cache/google-chrome/*
*.cache/mozilla/firefox*
*GoogleEarth/Cache/*
*GoogleEarth/Temp/*
*UHD Content/*
*vm-disks/*
._sync_*
.nextcloudsync.log
EOF
}
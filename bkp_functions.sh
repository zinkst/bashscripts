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
  setDateTimeString
  LOGFILENAME="${DATETIMESTRING}_${1}.log"
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
  MOUNTEDBYBKPSCRIPT="false"
  if [ -f ${MOUNTTESTFILE} ] 
  then
    echo ${MOUNTTESTFILE} "exists we can continue" | tee -a ${LOG_ROOT}${LOGFILENAME}
    TARGETFSMOUNTED="true"
  else
    if [ $1 == "false" -a ${TARGETFSMOUNTED} == "false" ]
	then
		echo ${MOUNTTESTFILE} "does not exist, please mount first"
	fi	
    if [ $1 == "true" ]
    then
    	echo ${MOUNTTESTFILE} "does not exist, trying to mount remote filesystem first" | tee -a ${LOG_ROOT}${LOGFILENAME}
    	mount ${REMOTEMOUNTPOINT} | tee -a ${LOG_ROOT}${LOGFILENAME}
      if [ -f ${MOUNTTESTFILE} ] 
      then
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
		index=$1
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
	HOSTNAME=`hostname`
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

#######################################################################################################
#old functions

Old_determineDistribution ()
{
	if [ -f /etc/fedora-release ]
	then
		DISTRIBUTION=`head -1 /etc/fedora-release | awk '{print $1 $3}'`
	elif [ -f /etc/redhat-release ]
	then
		DISTRIBUTION="OPENCLIENT"
	elif [ -f /etc/SuSE-release ]
	then
		DISTRIBUTION=`head -1 /etc/SuSE-release | awk '{print $1 $2}'`
	else
		uname -a | grep -i ubuntu
		if [ $? -eq 0 ]
		then 
			DISTRIBUTION="UBUNTU"
		else
			DISTRIBUTION="UNKNOWN"
		fi
	fi
}



copyOldTarFiles ()
{
    for index in index
    do
        echo -n "starting backup of ${Directories[index]}" >> ${BACKUPDIR}/${LOGFILENAME}
        date >> ${BACKUPDIR}/${LOGFILENAME}
        
        if [ -t ${BACKUPDIR}/${TargetNames[index]}_01.tgz ]
        then 
                echo "rm ${BACKUPDIR}/${TargetNames[index]}_01.tgz"
        fi
        echo -n "starting copy of ${BACKUPDIR}/${TargetNames[index]}.tgz to ${BACKUPDIR}/${TargetNames[index]}_01.tgz at" >> ${BACKUPDIR}/${LOGFILENAME}
        date >> ${BACKUPDIR}/${LOGFILENAME}
        echo "cp ${BACKUPDIR}/${TargetNames[index]}.tgz ${BACKUPDIR}/${TargetNames[index]}_01.tgz"
        cp ${BACKUPDIR}/${TargetNames[index]}.tgz ${BACKUPDIR}/${TargetNames[index]}_01.tgz
        echo -n "finished copy of ${BACKUPDIR}/${TargetNames[index]}_01.tgz to ${BACKUPDIR}/${TargetNames[index]}_01.tgz at" >> ${BACKUPDIR}/${LOGFILENAME}
        date >> ${BACKUPDIR}/${LOGFILENAME}
    done
}


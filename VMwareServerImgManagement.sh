#!/bin/bash

#############################################################################
#Programname: restore_backup
# Parameters : see usage
# Autor     : zinks
# Version   : 1.00
# Date      : 09/03/25
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# History:
############################################################################



checkVmwareFSMounted ()
{
  mount | grep /vmware
  RC=$?

  if [ $RC -ne 0 ]
  then
	echo "Filesystem /vmware ist not mountet. Try to mount..."
	mount /vmware
	if [ $? -ne 0 ]
	then
		if [ ! -d /vmware ]	
		then 
			echo "Exit Programm: Folder /vmware does not exist or no separat /vmware filesystem or problems to mount /vmware"
			exit 80
                fi
	   
	fi
  fi
}

checkVMwareGuestStatus ()
{
  if [ -f /usr/bin/vmware-cmd ]
  then
      echo "looks like a VMWare Server V1.x "
      checkVMwareGuestStatusV1
  else
      echo "looks like a VMWare Server V2.x "
      checkVMwareGuestStatusV2
  fi    
}

checkVMwareGuestStatusV1 ()
{
  VMWAREGUEST_STATUS=$(/usr/bin/vmware-cmd $VMWAREGUEST_VMX getstate| awk '{print $3}')
  echo "Guest status is ${VMWAREGUEST_STATUS}" 
  if [ "$VMWAREGUEST_STATUS"  == "on" ]
  then
    echo "Power Off VMware guest...."
    /usr/bin/vmware-cmd $VMWAREGUEST_VMX stop hard
    sleep 5
  fi
}

checkVMwareGuestStatusV2 ()
{
  VMID=$(vmware-vim-cmd vmsvc/getallvms | grep $VMHOSTNAME | awk '{print $1}')
  echo VMID=${VMID}
  VMSTATE=$(vmware-vim-cmd vmsvc/power.getstate ${VMID} | grep "Powered" | awk '{print $2}')
  echo VMSTATE=${VMSTATE}
  if [ "$VMSTATE"  == "on" ]
  then
    echo "Power Off VMware guest...."
    vmware-vim-cmd vmsvc/power.off $VMID
    sleep 5
  fi
}


deleteOldVM ()
{
  if [ -d ${VMDIR} ]
  then
    echo -e "Deleting directory ${VMDIR}:  \c ";date +%H:%M:%S
    rm -r ${VMDIR}
    echo -e "Successfully deleted:   \c"; date +%H:%M:%S
  fi
}

mountFileServer ()
{
  echo -e "Mount zipped image from ${IMAGESERVER}....\c";date +%H:%M:%S
  if [ -d ${IMAGEMOUNTPOINT} ]
  then
    mount ${IMAGESERVER}:${IMAGEPATH} ${IMAGEMOUNTPOINT}
    RC=$?
    if [ $RC -ne 0 ]
    then
      echo "Exit Programm: Image couldn't be mounted"
      exit 81
    else
      echo -e "Successfully mounted:   \c";date +%H:%M:%S
    fi
  else
    mkdir ${IMAGEMOUNTPOINT}
    mount ${IMAGESERVER}:${IMAGEPATH} ${IMAGEMOUNTPOINT}
    RC=$?
    if [ $RC -ne 0 ]
    then
      echo "Exit Programm: Imagepath couldn't be mounted"
      exit 81
    fi
    echo -e "Successfully mounted:   \c";date +%H:%M:%S
  fi
  ls -ld ${IMAGEMOUNTPOINT}
}

unpackImage ()
{
  echo -e "Extract image...:   \c";date +%H:%M:%S
  echo -e "running command: in ${VMDIR}" 
  tar --directory ${VMDIR} -xzf ${IMAGEMOUNTPOINT}/${IMAGENAME}
  echo -e "Successfully extracted:  \c"; date +%H:%M:%S
}

packImage ()
{
  echo -e "creating image...:   \c";date +%H:%M:%S
  echo -e "running command: in ${VMDIR}" 
  cd ${VMDIR}
  pwd 
  echo "running command: tar -czf ${IMAGEMOUNTPOINT}/${VMHOSTNAME}_${HOSTNAME}_${DATE}.tgz *"
  tar -czf ${IMAGEMOUNTPOINT}/${VMHOSTNAME}_${HOSTNAME}_${DATE}.tgz *
  echo -e "Successfully packed image:  \c"; date +%H:%M:%S
}


unmountFileServer ()
{
  umount -f ${IMAGEMOUNTPOINT}
  if [ $RC -ne 0 ]
  then
    echo "Exit Programm: Image couldn't be unmounted"
    exit 82
  else
    echo -e "Filesystem successfully unmounted:   \c";date +%H:%M:%S
  fi
}

continueOrExit ()
{
  echo -e "Do you want to continue\nANSWER: (y/n): \c"
  read answer 
  if [ "$answer" != "y" ]
  then
    echo "n or wrong input. Progrmm Exit"
    exit 99
  fi
}

checkAndCreateDir ()
{
  echo "check and create Dir if not present ${1}"
  if [ ! -d ${1} ]
  then
    mkdir -p ${1}
  fi 
}

usage ()
{
  echo "call ${0} [-i <IMAGENAME> ] [-v <VMHOSTNAME>] [-p <IMAGEPATH>] [-s <IMAGESERVER>] [-n <VMXNAME>] (-r | -b) "
  echo "samples are:"
  echo "IMAGENAME=${IMAGENAME}"
  echo "VMHOSTNAME=${VMHOSTNAME}"
  echo "IMAGEPATH=${IMAGEPATH}"
  echo "IMAGESERVER=${IMAGESERVER}"
  echo "VMXNAME=${VMXNAME}"
  echo " -r -> restore image"
  echo " -b -> create backup image"
  exit 0; 

}

#######################################
# main starts here
# intialize Parameters (may be overwritten with input parameter)
IMAGENAME=ccmdbadminsrv_TE_BASIC.tgz
#IMAGENAME=ImageNameNotUsedInBackupMode.tgz
VMHOSTNAME=vmwsXXX
IMAGEPATH=/vol/sapcds/testenv/backups/
IMAGESERVER=d2705nas1a
VMXNAME=ccmdbadminsrv.vmx
MODE=unknown
IMAGEMOUNTPOINT=/image

while getopts ":i:v:p:s:n:hrb" OPTNAME
  do
    case "${OPTNAME}" in
      "h")
	echo "Option ${OPTNAME} is specified"
	usage
	exit 0; 
	;;
      "i")
	echo "Option ${OPTNAME} is specified"
	IMAGENAME=${OPTARG} 
	;;
      "v")
	echo "Option ${OPTNAME} is specified"
	VMHOSTNAME=${OPTARG} 
	;;
      "p")
	echo "Option ${OPTNAME} is specified"
	IMAGEPATH=${OPTARG} 
	;;
      "n")
	echo "Option ${OPTNAME} is specified"
	VMXNAME=${OPTARG} 
	;;
      "s")
	echo "Option ${OPTNAME} is specified"
	IMAGESERVER=${OPTARG} 
	;;
      "r")
	echo "Option ${OPTNAME} is specified"
	if [ ${MODE} == "unknown" ]
	then
	  MODE="restore"
        else
	  echo "duplicate mode set ... exiting" 
	  usage
	  exit 0
        fi 
	;;
      "b")
	echo "Option ${OPTNAME} is specified"
	if [ ${MODE} == "unknown" ]
	then
	  MODE="backup"
        else
	  echo "duplicate mode set ... exiting" 
	  usage
	  exit 0
        fi
	;;
      "?")
	echo "Unknown option $OPTARG"
	;;
      ":")
	echo "No argument value for option $OPTARG"
	;;
      *)
      # Should not occur
	echo "Unknown error while processing options"
	;;
    esac
    #echo "OPTIND is now $OPTIND"
  done

IMAGE=${IMAGEPATH}${IMAGENAME}
VMDIR=/vmware/${VMHOSTNAME}
VMWAREGUEST_VMX=${VMDIR}/${VMXNAME}
HOSTNAME=$(hostname)
DATE=$(date +%y%m%d%H%M)


RC=0
echo "IMAGENAME	 	=${IMAGENAME}"
echo "VMHOSTNAME 	=${VMHOSTNAME}"
echo "IMAGEPATH	 	=${IMAGEPATH}"
echo "IMAGE	 	=${IMAGE}"
echo "IMAGESERVER	=${IMAGESERVER}"
echo "IMAGEMOUNTPOINT 	=${IMAGEMOUNTPOINT}"
echo "VMDIR	 	=${VMDIR}"
echo "VMWAREGUEST_VMX 	=${VMWAREGUEST_VMX}"
echo "HOSTNAME	 	=${HOSTNAME}"
echo "DATE 		=${DATE}"

case ${MODE} in
  "restore")
      echo "restore operation selected"
      #continueOrExit
      checkVmwareFSMounted
      checkVMwareGuestStatus
      deleteOldVM
      mountFileServer
      checkAndCreateDir ${VMDIR}
      unpackImage
      unmountFileServer
      ;;
  "backup")
      echo "backup operation selected"
      #continueOrExit
      checkVmwareFSMounted
      checkVMwareGuestStatus
      mountFileServer
      packImage
      unmountFileServer
      ;;
  "*")
     echo "mode not specified"
     usage
     exit 0
     ;; 
esac  
#/bin/bash

# variables
BACKUPDIR="/local/backup/tarbkp"
#CORRECTHOST="zinkstp.boeblingen.de.ibm.com"
CORRECTHOST="zinkstp"
LOG_ROOT="/local/backup/tarbkp/"
TAROPTS="cpvzf"
REMOTEMOUNTPOINT=/remote/veins02/zinks
SERVERIP=veins02.boeblingen.de.ibm.com
MOUNTTESTFILE="${REMOTEMOUNTPOINT}/do_not_delete"
DESTINATIONBACKUPDIR="${REMOTEMOUNTPOINT}/tarbkp/${CORRECTHOST}"
MOUNTEDBYBKPSCRIPT="false"

# for development initialize variables"
#LOGFILENAME="devtest.log"
#SERVERPINGABLE="true"
#EXTENSION="tar"
DATAPATH="/local/data"

Directories[1]="${DATAPATH}/homes/"
TargetNames[1]="zinkstp_homes"
TarOpts[1]=${TAROPTS}
Directories[2]="${DATAPATH}/persdata"
TargetNames[2]="zinkstp_persdata"
TarOpts[2]=${TAROPTS}
Directories[3]="${DATAPATH}/workdata"
TargetNames[3]="zinkstp_workdata"
TarOpts[3]=${TAROPTS}
Directories[4]="${DATAPATH}/Photos/2010"
TargetNames[4]="zinkstp_Photos_2010"
TarOpts[4]="cpvf"
Directories[5]="${DATAPATH}/Photos/unsorted"
TargetNames[5]="zinkstp_Photos_unsorted"
TarOpts[5]="cpvf"
Directories[6]="${DATAPATH}/lx_workspaces/ibmdi"
TargetNames[6]="zinkstp_lx_workspaces_ibmdi"
TarOpts[6]=${TAROPTS}
Directories[7]="${DATAPATH}/lx_workspaces/private_ws"
TargetNames[7]="zinkstp_lx_workspaces_private_ws"
TarOpts[7]=${TAROPTS}
Directories[8]="${DATAPATH}/lx_workspaces/gershwin"
TargetNames[8]="zinkstp_lx_workspaces_gershwin"
TarOpts[8]=${TAROPTS}

. /root/bin/bkp_functions.sh

# main routine

if [ -z ${1} ]
then
    index="1 2 3 4 5 7"
else
    index=${1}
fi


if vmware_inVM;
then
  echo "running in VM"
  exit 0
else
  echo "running Native"
  setLogfileName startup
  checkCorrectHost
  #testServerPing
  createTars
  setLogfileName startup
  #checkFSMounted "true"
  #if [ ${TARGETFSMOUNTED} == "true" ]
  #then
  #    echo "copyTarFilesToDestination"
  #    copyTarFilesToDestination 
  #fi
  #if [ ${MOUNTEDBYBKPSCRIPT} == "true" ]
  #then
  #    echo "trying to umount ${REMOTEMOUNTPOINT}" | tee -a ${LOG_ROOT}${LOGFILENAME}
  #    umount ${REMOTEMOUNTPOINT}
  #fi
fi    

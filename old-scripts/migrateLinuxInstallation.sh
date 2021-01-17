#!/bin/bash

. /links/bashscripts/bkp_functions.sh

SHFILES[1]="etc/agnclient/agnclient.conf"
SHFILES[2]="etc/exports"
SHFILES[3]="etc/samba"
SHFILES[4]="links"
SHFILES[5]="remote"
SHFILES[6]="local"
SHFILES[7]="nfs4exports"
SHFILES[8]="etc/profile.d/szUmask.sh"
SHFILES[9]="etc/rc.local"
SHFILES[10]="etc/fstab"
SHFILES[11]="etc/adsm"
SHFILES[12]="etc/crontab"
SHFILES[13]="etc/hosts"
SHFILES[14]="etc/sane.d/snapscan.conf"


FEDFILES[1]="etc/dhclient-eth0.conf"
FEDFILES[2]="etc/dhclient-wlan0.conf"
FEDFILES[3]="etc/rc.d/rc.local"
FEDFILES[4]="etc/systemd/system/dsmcad.service"
FEDFILES[5]="opt/tivoli/tsm/client/ba/bin/dsm.sys"
FEDFILES[6]="opt/tivoli/tsm/client/ba/bin/dsm.opt"

UBUFILES[1]="etc/dhcp/dhclient.conf"
UBUFILES[2]="etc/init/dsmcad.conf"
UBUFILES[3]="etc/udev/rules.d/81-thinkpad-dock.rules"

setDateTimeString
MOVE_EXTENSION=${DATETIMESTRING}
MOVE_EXTENSION="F15toF16"

SRC_FOLDER="/local/fedora/"
TGT_FOLDER="/"

SH_INDEX="1 2 3 4 5 6 7 8 9 10 11 12"
FED_INDEX="1 2" 
UBU_INDEX="1 2 3 " 

SH_INDEX=" "
FED_INDEX=" 5 6" 
UBU_INDEX=" " 



processFedFiles ()
{
	echo "processing files for Fedora"
	for idx in ${FED_INDEX}
	do
		moveFileNoTargetOverwrite ${TGT_FOLDER}${FEDFILES[idx]} ${TGT_FOLDER}${FEDFILES[idx]}.${MOVE_EXTENSION}
		copyFile ${SRC_FOLDER}${FEDFILES[idx]} ${TGT_FOLDER}${FEDFILES[idx]}
	done
}

processUbuFiles ()
{
	for idx in ${UBU_INDEX}
	do
		moveFileNoTargetOverwrite ${TGT_FOLDER}${UBUFILES[idx]} ${TGT_FOLDER}${UBUFILES[idx]}.${MOVE_EXTENSION}
		copyFile ${SRC_FOLDER}${UBUFILES[idx]} ${TGT_FOLDER}${UBUFILES[idx]}
	done
}

TESTFLAG="false"
while getopts "td:" Option
do
    case $Option in
        t    ) TESTFLAG="true";;
        d    )         
			echo "Option ${OPTNAME} is specified"
			DISTRIBUTION=${OPTARG} 
        ;;
    esac
done

echo "TESTFLAG=${TESTFLAG}"    

echo DISTRIBUTION=${DISTRIBUTION}
case "${DISTRIBUTION}" in
	Ubuntu )
		echo "processing files for Ubuntu"
		processUbuFiles
		;;
	Fedora )	
		echo "processing files for Fedora"
		processFedFiles
		;;
    * )
      echo "Distribution not set , exiting"
      exit -1 
    ;;  
esac


for idx in ${SH_INDEX}
do
    moveFileNoTargetOverwrite ${TGT_FOLDER}${SHFILES[idx]} ${TGT_FOLDER}${SHFILES[idx]}.${MOVE_EXTENSION}
    copyFile ${SRC_FOLDER}${SHFILES[idx]} ${TGT_FOLDER}${SHFILES[idx]}
done


#!/bin/bash
REMOTEMOUNTPOINT="/remote/bbback07"
SERVERIP="bbback07.boeblingen.de.ibm.com"
#CORRECTHOST="zinkstp.boeblingen.de.ibm.com"
CORRECTHOST="zinkstp"
TARGETFILENAME="zinks.tar"
MOUNTTESTFILE="${REMOTEMOUNTPOINT}/${TARGETFILENAME}"
DESTINATIONBACKUPDIR="${REMOTEMOUNTPOINT}/tarbkp/${CORRECTHOST}"
SRCROOTDIR="/links/backup"

. /home/zinks/bin/bkp_functions.sh

FILES[1]="${SRCROOTDIR}/sysbkp/*.tgz"
FILES[2]="${SRCROOTDIR}/sysbkp/*.gz"
FILES[3]="${SRCROOTDIR}/tarbkp/*.tgz"
FILES[4]="${SRCROOTDIR}/tarbkp/*.tar"


createTarFile ()
{
    setDateTimeString
    echo "rm ${REMOTEMOUNTPOINT}/${TARGETFILENAME}"
    rm ${REMOTEMOUNTPOINT}/${TARGETFILENAME}
    echo "starting creation of ${REMOTEMOUNTPOINT}/${TARGETFILENAME} at" 
    date 
    echo "tar cvf ${REMOTEMOUNTPOINT}/${TARGETFILENAME} ${FILES[1]} ${FILES[2]} ${FILES[3]} ${FILES[4]}"
    tar cvf ${REMOTEMOUNTPOINT}/${TARGETFILENAME} ${FILES[1]} ${FILES[2]} ${FILES[3]} ${FILES[4]}
    echo "finished creation of ${REMOTEMOUNTPOINT}/${TARGETFILENAME} at" 
    date 
}

# main starts here

checkCorrectHost
testServerPing
checkFSMounted "true"
# test
#createTarFile
# test
if [ ${TARGETFSMOUNTED} == "true" ]
then
    echo "createTarFile"
    createTarFile
fi
if [ ${MOUNTEDBYBKPSCRIPT} == "true" ]
then
    echo "trying to umount ${REMOTEMOUNTPOINT}" 
    umount ${REMOTEMOUNTPOINT}
fi

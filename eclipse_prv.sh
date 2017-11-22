#!/bin/bash
. /links/bin/bkp_functions.sh
determineDistribution
java_env "open"
echo "starting ${PROGRAM_DIR}/eclipse #-vm ${JAVA_PROGRAM_DIR} "

if [ `uname -m` = "x86_64" ]
then
    PROGRAM_DIR="/home/share/eclipse_prv"	
else
    PROGRAM_DIR="/home/share/eclipse_prv_32"	
fi    

cd ${PROGRAM_DIR}
pwd
#export CMD="GDK_DPI_SCALE=1.5 ${PROGRAM_DIR}/eclipse -vm ${JAVA_HOME}bin &"
export CMD="${PROGRAM_DIR}/eclipse -vm ${JAVA_HOME}bin &"
echo ${CMD}
${CMD}

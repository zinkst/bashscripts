#!/bin/bash
. /links/bashscripts/bkp_functions.sh
determineDistribution
java_env "open"
echo "starting ${PROGRAM_DIR}/eclipse #-vm ${JAVA_PROGRAM_DIR} "

#if [ `uname -m` = "x86_64" ]
#then
#    PROGRAM_DIR="/home/share/eclipse_wrk_64"	
#else
#    PROGRAM_DIR="/home/share/eclipse_wrk"	
#fi    

PROGRAM_DIR="/home/share/eclipse_wrk_32"	
GROOVY_HOME="${PROGRAM_DIR}/groovy-1.7.10"
PATH=$PATH:"$GROOVY_HOME/bin"

cd ${PROGRAM_DIR}
pwd
export CMD="${PROGRAM_DIR}/eclipse -vm ${PROGRAM_DIR}/ibm-java-i386-60/bin &"
echo ${CMD}
${CMD}

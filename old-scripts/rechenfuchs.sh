#!/bin/bash
. /links/bashscripts/bkp_functions.sh
determineDistribution
java_env "open"

######## CONFIGURATION OPTIONS ########
PROGRAM_DIR="/home/share/RechenfuchsAbakus/Deso/Abakus/Version0.99"	
STARTJAR_NAME="abakus.jar"
cd ${PROGRAM_DIR}
pwd
echo "starting ${JAVA_PROGRAM_DIR}java -jar ${PROGRAM_DIR}/${STARTJAR_NAME} "
${JAVA_PROGRAM_DIR}java -jar ${PROGRAM_DIR}/${STARTJAR_NAME} &

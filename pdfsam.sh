#!/bin/bash
. /links/bin/bkp_functions.sh
determineDistribution
java_env open
######## CONFIGURATION OPTIONS ########
#JAVA_PROGRAM_DIR="/etc/alternatives/java_sdk_1.5.0/bin/"	
#JAVA_PROGRAM_DIR="/usr/lib/jvm/jre-1.6.0-ibm/bin/"	
PROGRAM_DIR="/home/share/pdfsam"	# use full path to Azureus bin dir
cd ${PROGRAM_DIR}
STARTJAR_NAME=$(ls pdfsam*.jar | cut -d '/' -f 2)
#######################################

echo "starting ${JAVA_PROGRAM_DIR}java -jar ${PROGRAM_DIR}/${STARTJAR_NAME} "
${JAVA_PROGRAM_DIR}java -jar ${PROGRAM_DIR}/${STARTJAR_NAME} 

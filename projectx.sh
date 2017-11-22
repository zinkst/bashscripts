#!/bin/bash
. /links/bin/bkp_functions.sh
determineDistribution
java_env "open"


######## CONFIGURATION OPTIONS ########
#JAVA_PROGRAM_DIR="/etc/alternatives/java_sdk_1.5.0/bin/"	
PROGRAM_DIR="/home/share/ProjectX"	
STARTJAR_NAME="ProjectX.jar"
#######################################

echo "starting ${JAVA_PROGRAM_DIR}java -jar ${PROGRAM_DIR}/${STARTJAR_NAME} "
${JAVA_PROGRAM_DIR}java -jar ${PROGRAM_DIR}/${STARTJAR_NAME} 

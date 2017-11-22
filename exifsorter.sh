#!/bin/bash

######## CONFIGURATION OPTIONS ########
JAVA_PROGRAM_DIR="/etc/alternatives/java_sdk_1.5.0/bin/"	
PROGRAM_DIR="/home/share/AmokExifSorter"
STARTJAR_NAME="Exifsorter.jar"
#######################################

echo "starting ${JAVA_PROGRAM_DIR}java -jar ${PROGRAM_DIR}/${STARTJAR_NAME}"
${JAVA_PROGRAM_DIR}java -Djava.library.path=${PROGRAM_DIR} -jar ${PROGRAM_DIR}/${STARTJAR_NAME} &

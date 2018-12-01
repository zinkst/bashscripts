#!/bin/bash
. /links/bin/bkp_functions.sh
determineDistribution
java_env open
######## CONFIGURATION OPTIONS ########
#JAVA_PROGRAM_DIR="/etc/alternatives/java_sdk_1.5.0/bin/"	
JAVA_PROGRAM_DIR="/usr/lib/jvm/java-10-openjdk-10.0.2.13-7.fc29.x86_64/bin/"	
JAVA_PROGRAM_DIR="/home/share/oracle-jdk/jdk-11.0.1/bin/"
export PATH_TO_FX="/home/share/oracle-jdk/javafx-sdk-11.0.1/lib"
PROGRAM_DIR="/home/share/pdfsam"	# use full path to Azureus bin dir
cd ${PROGRAM_DIR}
STARTJAR_NAME=$(ls pdfsam*.jar | cut -d '/' -f 2)
#######################################

echo "starting ${JAVA_PROGRAM_DIR}java -jar ${PROGRAM_DIR}/${STARTJAR_NAME} "
${JAVA_PROGRAM_DIR}java --module-path $PATH_TO_FX --add-modules=javafx.controls -jar ${PROGRAM_DIR}/${STARTJAR_NAME} 

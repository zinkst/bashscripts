#!/bin/bash
. ${HOME}/bin/java_env.sh

######## CONFIGURATION OPTIONS ########
#JAVA_PROGRAM_DIR="/etc/alternatives/java_sdk_1.5.0/bin/"	
PROGRAM_DIR="/home/share/jxplorer"	# use full path to Azureus bin dir
PRG_CP=".:jars/jxplorer.jar:jars/help.jar:jars/jhall.jar:jars/junit.jar:jars/ldapsec.jar:jars/log4j.jar:jars/dsml/activation.jar:jars/dsml/commons-logging.jar:jars/dsml/dom4j.jar:jars/dsml/jxext.jar:jars/dsml/mail.jar:jars/dsml/providerutil.jar:jars/dsml/saaj-api.jar:jars/dsml/saaj-ri.jar" 
PRG_MAIN_CLASS="com.ca.directory.jxplorer.JXplorer"
#######################################

cd ${PROGRAM_DIR}
pwd
echo "starting ${JAVA_PROGRAM_DIR}java -cp ${PRG_CP} ${PRG_MAIN_CLASS} "
${JAVA_PROGRAM_DIR}java -cp ${PRG_CP} ${PRG_MAIN_CLASS} &

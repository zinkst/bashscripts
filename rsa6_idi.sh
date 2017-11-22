#!/bin/bash

######## CONFIGURATION OPTIONS ########
export JAVA_HOME="/etc/alternatives/java_sdk_1.4.2"
export PATH="/usr/lib/jvm/java-1.4.2/bin/:"$PATH
export DB2_HOME="/home/db2inst1/sqllib/"
#export ANT_HOME="/opt/eclipse_wtp/plugins/org.apache.ant_1.6.5/"
export LANG=en_US.ISO8859-1
export RSA_HOME="/opt/IBM/Rational/SDP/6.0"
JAVA_15_PROGRAM_DIR="/etc/alternatives/java_sdk_1.5.0/bin/java"	

#pwd
#. /home/db2inst1/sqllib/db2profile
cd ${RSA_HOME}
echo "starting ${RSA_HOME}/rationalsdp.bin"
${RSA_HOME}/rationalsdp.bin & #-vm ${JAVA_15_PROGRAM_DIR} &

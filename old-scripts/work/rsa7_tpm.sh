#!/bin/bash

######## CONFIGURATION OPTIONS ########
#JAVA_PROGRAM_DIR="/etc/alternatives/java_sdk_1.4.2/bin/java"	
JAVA_HOME="/opt/IBM/SDP70/runtimes/base_v61/java"	
PROGRAM_DIR="/opt/IBM/SDP70"	
#PROGRAM_DIR="/opt/eclipse_33prv"	
#######################################
export PATH=${JAVA_HOME}/bin:$PATH
export DB2_HOME="/home/db2inst1/sqllib/"
#export ANT_HOME="/opt/eclipse_wtp/plugins/org.apache.ant_1.6.5/"
export LANG=en_US.ISO8859-1
export PRODUCT="com.ibm.rational.rsa.product.ide"
cd ${PROGRAM_DIR}
pwd
. /home/db2inst1/sqllib/db2profile
echo "starting ${PROGRAM_DIR}/eclipse -product ${PRODUCT} -vm ${JAVA_HOME}/bin/java"
${PROGRAM_DIR}/eclipse -product ${PRODUCT} -vm ${JAVA_HOME}/bin/java &

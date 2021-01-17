#!/bin/bash

JAVA_HOME="/etc/alternatives/java_sdk_1.5.0"	
PRG_HOME="/home/share/ldapbrowser"
JNDI_LIB=lib/ldap.jar:lib/jndi.jar:lib/providerutil.jar:lib/ldapbp.jar
JSSE_LIB=lib/jsse.jar:lib/jnet.jar:lib/jcert.jar

COMMON=.:${JNDI_LIB}:${JSSE_LIB}
EXEC='browser.jar lbe.ui.BrowserApp'

cd ${PRG_HOME}
CMD="${JAVA_HOME}/bin/java -cp ${COMMON}:${EXEC}"

echo ${CMD}
${CMD} &


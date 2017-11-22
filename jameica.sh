#!/bin/sh
# Linux Start-Script fuer regulaeren Standalone-Betrieb.
# Jameica wird hierbei mit GUI gestartet.

. /links/bin/bkp_functions.sh
determineDistribution

java_env "open"
#_JCONSOLE="-Dcom.sun.management.jmxremote"
JAMEICA_DIR=/home/share/jameica
cd ${JAMEICA_DIR}
echo ${JAVA_HOME}

bit=`arch |grep 64`
if [ $? = 0 ]
 then  
    LIBOVERLAY_SCROLLBAR=0 GDK_NATIVE_WINDOWS=1 SWT_GTK3=0 ${JAVA_HOME}/bin/java -Xmx512m $_JCONSOLE -jar jameica-linux64.jar $@
 else 
    LIBOVERLAY_SCROLLBAR=0 GDK_NATIVE_WINDOWS=1 SWT_GTK3=0 ${JAVA_HOME}/bin/java -Xmx512m $_JCONSOLE -jar jameica-linux.jar $@
fi

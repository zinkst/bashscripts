#!/bin/sh
#
#  Script:		SMclient.CATERA
#  Instance:		2
#  %version:		14 %
#  Description:		
#  %created_by:		gbain %
#  %date_created:	Thu Apr 02 13:38:52 2009 %

BASEDIR=/opt/IBM_DS
#JAVA_EXEC=$BASEDIR/jre/bin/java
JAVA_EXEC=/etc/alternatives/java
INI_HEAP=-Xmx256m
FFEAT=FULL_SA
SANSIM=SANTRICITY
MOTIF="-Dswing.defaultlaf=com.sun.java.swing.plaf.motif.MotifLookAndFeel"
STORAGE_MANAGER_TYPE=5

# Test to see if we can connect to the X Server
xdpyinfo 1>/dev/null
if [ $? = 1 ]; then exit; fi

# Set up environment for non-English users
export LC_ALL=C

$JAVA_EXEC -Ddevmgr.datadir=/var/opt/SM -Ddevmgr.dmv.featureOption=$FFEAT $MOTIF -DstorageManager=$STORAGE_MANAGER_TYPE -classpath $BASEDIR/client/SMclient.jar:$BASEDIR/client/jhall.jar:$BASEDIR/client/swing_layout.jar:$BASEDIR/client $INI_HEAP devmgr.dmv.MainScreen 2>/dev/null &

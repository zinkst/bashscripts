SAMETIME_SRC_FOLDER="/links/workdata/Lotus/SametimeEssentialFiles"
SAMETIME_TGT_FOLDER="/home/zinks/lotus/Sametime"
SAMETIME_PLUGIN_SUBDIR="${SAMETIME_TGT_FOLDER}/.metadata/.plugins"

. /links/bashscripts/bkp_functions.sh


FILESRC[1]=com.ibm.collaboration.realtime.location
FILETGT[1]=${SAMETIME_PLUGIN_SUBDIR}/${FILESRC[1]}
FILESRC[2]=com.ibm.collaboration.realtime.imhub
FILETGT[2]=${SAMETIME_PLUGIN_SUBDIR}/${FILESRC[2]}
FILESRC[3]=com.ibm.collaboration.realtime.contact.storage
FILETGT[3]=${SAMETIME_PLUGIN_SUBDIR}/${FILESRC[3]}
FILESRC[4]=com.ibm.collaboration.realtime.primarybuddies
FILETGT[4]=${SAMETIME_PLUGIN_SUBDIR}/${FILESRC[4]}
FILESRC[5]=com.ibm.collaboration.realtime.telephony.sut.callhistory
FILETGT[5]=${SAMETIME_PLUGIN_SUBDIR}/${FILESRC[5]}
FILESRC[6]=com.ibm.collaboration.realtime.palettes
FILETGT[6]=${SAMETIME_PLUGIN_SUBDIR}/${FILESRC[6]}
FILESRC[7]=com.voicerite.vc3.desktop.ui.prefs
FILETGT[7]=${SAMETIME_PLUGIN_SUBDIR}/org.eclipse.core.runtime/.settings/${FILESRC[7]}
FILESRC[8]=com.voicerite.vc3.resources.prefs
FILETGT[8]=${SAMETIME_PLUGIN_SUBDIR}/org.eclipse.core.runtime/.settings/${FILESRC[8]}
FILESRC[9]=com.ibm.ie.brian_odonovan.smasher
FILETGT[9]=${SAMETIME_PLUGIN_SUBDIR}/${FILESRC[9]}
FILESRC[10]=ucpStOEM
FILETGT[10]=${SAMETIME_TGT_FOLDER}/${FILESRC[10]}





setDateTimeString
MOVE_EXTENSION=${DATETIMESTRING}

COPYFLAG="false"
TESTFLAG="false"
#PROCESS ARGS
while getopts "tc" Option
do
    case $Option in
        t    ) TESTFLAG="true";;
        c    ) COPYFLAG="true";;
    esac
done


cd ${SAMETIME_PLUGIN_SUBDIR}
echo "PWD=" `pwd`

echo "TESTFLAG=${TESTFLAG}"    
index="1 2 3 4 5 6 7 8 10"
#index="10"

for crtIdx in $index
do
    moveFile ${FILETGT[crtIdx]} ${FILETGT[crtIdx]}.${MOVE_EXTENSION}
    if [ ${COPYFLAG} == "true" ]
    then 
        copyFile ${SAMETIME_SRC_FOLDER}/${FILESRC[crtIdx]} ${FILETGT[crtIdx]}
    else
        linkFile ${SAMETIME_SRC_FOLDER}/${FILESRC[crtIdx]} ${FILETGT[crtIdx]}
    fi    
done

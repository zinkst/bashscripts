#NOTES_SRC_FOLDER="../EssentialFiles"
NOTES_SRC_FOLDER="/links/workdata/Lotus/Notes/EssentialFiles"
FQ_NOTES_SRC_FOLDER="/links/workdata/Lotus/Notes/EssentialFiles"
SAMETIME_SRC_FOLDER="../../../../../SametimeEssentialFiles"
FQ_SAMETIME_SRC_FOLDER="/links/workdata/Lotus/SametimeEssentialFiles"
NOTES_TGT_FOLDER="${HOME}/lotus/notes/data"
NOTES_PLUGIN_SUBDIR="${NOTES_TGT_FOLDER}/workspace/.metadata/.plugins"

. /links/bin/lib/bkp_functions.sh
#. /home/zinks/bin/updateSametimeProfile.sh


FILESRC[1]=archive
FILETGT[1]=${NOTES_TGT_FOLDER}/${FILESRC[1]}
FILESRC[2]=bookmark.nsf
FILETGT[2]=${NOTES_TGT_FOLDER}/${FILESRC[2]}
FILESRC[3]=names.nsf
FILETGT[3]=${NOTES_TGT_FOLDER}/${FILESRC[3]}
FILESRC[4]=desktop8.ndk
FILETGT[4]=${NOTES_TGT_FOLDER}/${FILESRC[4]}
FILESRC[5]=c_dir
FILETGT[5]=${NOTES_TGT_FOLDER}/${FILESRC[5]}
FILESRC[6]=De109612.id
FILETGT[6]=${NOTES_TGT_FOLDER}/${FILESRC[6]}
FILESRC[7]=test.tst
FILETGT[7]=${NOTES_TGT_FOLDER}/${FILESRC[7]}

FILESRC[10]=com.ibm.collaboration.realtime.location
FILETGT[10]=${NOTES_PLUGIN_SUBDIR}/${FILESRC[10]}
FILESRC[11]=com.ibm.collaboration.realtime.imhub
FILETGT[11]=${NOTES_PLUGIN_SUBDIR}/${FILESRC[11]}
FILESRC[12]=com.ibm.collaboration.realtime.telephony.ui.internal
FILETGT[12]=${NOTES_PLUGIN_SUBDIR}/${FILESRC[12]}
FILESRC[13]=com.ibm.collaboration.realtime.contact.storage
FILETGT[13]=${NOTES_PLUGIN_SUBDIR}/${FILESRC[13]}
FILESRC[14]=com.ibm.collaboration.realtime.primarybuddies
FILETGT[14]=${NOTES_PLUGIN_SUBDIR}/${FILESRC[14]}
FILESRC[15]=com.ibm.collaboration.realtime.telephony.sut.callhistory
FILETGT[15]=${NOTES_PLUGIN_SUBDIR}/${FILESRC[15]}
FILESRC[16]=com.ibm.collaboration.realtime.palettes
FILETGT[16]=${NOTES_PLUGIN_SUBDIR}/${FILESRC[16]}
FILESRC[17]=com.voicerite.vc3.desktop.ui.prefs
FILETGT[17]=${NOTES_PLUGIN_SUBDIR}/org.eclipse.core.runtime/.settings/${FILESRC[17]}
FILESRC[18]=com.voicerite.vc3.resources.prefs
FILETGT[18]=${NOTES_PLUGIN_SUBDIR}/org.eclipse.core.runtime/.settings/${FILESRC[18]}
FILESRC[19]=com.ibm.ie.brian_odonovan.smasher
FILETGT[19]=${NOTES_PLUGIN_SUBDIR}/${FILESRC[19]}
FILESRC[20]=ucpStOEM
FILETGT[20]=${NOTES_TGT_FOLDER}/workspace/${FILESRC[20]}

setDateTimeString
MOVE_EXTENSION=${DATETIMESTRING}

COPYFLAG="false"
TESTFLAG="false"
INCLUDESAMETIME="false"
#PROCESS ARGS
while getopts "tcs" Option
do
    case $Option in
        t    ) TESTFLAG="true";;
        c    ) COPYFLAG="true";;
        s    ) INCLUDESAMETIME="true";;
    esac
done


echo "TESTFLAG=${TESTFLAG}"    
notesindex="1 2 3 4 5 6"
sametimeindex="10 11 12 13 14 15 16 17 18 20" 

#notesindex="1 2 3 4 5"
#sametimeindex="10 11 12 13 14 15 16 17 18 19 20" 

cd ${NOTES_TGT_FOLDER}
echo "PWD=" `pwd`
SRC_FOLDER=${FQ_NOTES_SRC_FOLDER}
for crtIdx in $notesindex
do
    moveFile ${FILETGT[crtIdx]} ${FILETGT[crtIdx]}.${MOVE_EXTENSION}
    if [ ${COPYFLAG} == "true" ]
    then 
      copyFile ${SRC_FOLDER}/${FILESRC[crtIdx]} ${FILETGT[crtIdx]}
    else
      linkFile ${SRC_FOLDER}/${FILESRC[crtIdx]} ${FILETGT[crtIdx]}
    fi  
done

if [ ${INCLUDESAMETIME} == "true" ]
then 
  cd ${NOTES_PLUGIN_SUBDIR}
  echo "PWD=" `pwd`
  SRC_FOLDER=${FQ_SAMETIME_SRC_FOLDER}
  for crtIdx in $sametimeindex
  do
      moveFile ${FILETGT[crtIdx]} ${FILETGT[crtIdx]}.${MOVE_EXTENSION}
      if [ ${COPYFLAG} == "true" ]
      then 
        copyFile ${SRC_FOLDER}/${FILESRC[crtIdx]} ${FILETGT[crtIdx]}
      else
        linkFile ${SRC_FOLDER}/${FILESRC[crtIdx]} ${FILETGT[crtIdx]}
      fi    
  done
fi 


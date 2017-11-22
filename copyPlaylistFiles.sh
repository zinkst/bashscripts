#!/bin/bash
PLAYLIST=/links/Musik/Playlists/kinder.m3u8
TEMP_FILE=/tmp/tmpPlList.m3u
TGT_DIR=/tmp/tmpPlList
grep -va "\#" ${PLAYLIST} > ${TEMP_FILE}
sed -i "s/shares\/Filer/remote\/WDMyCloud1\/cifs/g" ${TEMP_FILE}
#$(echo ${TEMP_FILE} | recode "UTF-8..ISO-8859-1") > ${TEMP_FILE}
if [ ! -f ${TGT_DIR} ];
then 
  mkdir -p ${TGT_DIR}
fi  
while read -r i
do
  #echo "${i}"
  cmd="cp \"${i}\" ${TGT_DIR}"
  echo ${cmd}
  eval ${cmd}
done < "${TEMP_FILE}"


#for i in $(cat ${TEMP_FILE}); do
  #echo "${i}"
  #cmd="cp \"${i}\" ${TGT_DIR}"
  #echo ${cmd}
#done
#rm temp_file

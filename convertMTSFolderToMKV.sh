#!/bin/bash
# This command takes all videos in VIDEO_DIR/input and does
# * merges all videos into one video uning ffmepg
# * it writes the timestamp of the first video file to the generated output file
# * generates an outputfilename based on input parameter and timestamp of first input file

getTimestamps()
{
  EXTENSION="${FBNAME##*.}"
  echo "EXTENSION=${EXTENSION}"
  if [ "${EXTENSION}" == "MTS" ]; then
	  TIMESTAMP=$(mediainfo --Inform="General;%Recorded_Date%" "${1}")
  else 
	  TIMESTAMP=$(mediainfo --Inform="Video;%Encoded_Date%" "${1}")
	  ## hardcode timestamp if not available
    #TIMESTAMP="UTC 2013-05-24 19:35:22"
  	TIMESTAMP=${TIMESTAMP:4}
  fi	
  
  echo "MEDIATIMESTAMP=$TIMESTAMP" # UTC 2020-01-18 13:27:09
  ORIGTIMESTAMP_UNIX_UTC=$(TZ=UTC date +'%s' -d "${TIMESTAMP}")
  echo "ORIGTIMESTAMP_UNIX_UTC=${ORIGTIMESTAMP_UNIX_UTC}"
  ORIGTIMESTAMP_UNIX=$(TZ="Europe/Berlin" date +'%s' -d@"${ORIGTIMESTAMP_UNIX_UTC}")
  #echo "ORIGTIMESTAMP_UNIX=${ORIGTIMESTAMP_UNIX}"
  ORIGTIMESTAMP_ISO8601=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%dT%H%M%S')
  #echo "ORIGTIMESTAMP_ISO8601=${ORIGTIMESTAMP_ISO8601}"
  #ORIGTIMESTAMP_UNIX=`stat -c %Y "${1}"`
  ORIGTIMESTAMP=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d_%H%M%S')
  ORIGTIMESTAMP4FILENAME=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%m%d')
  echo "ORIGTIMESTAMP=${ORIGTIMESTAMP}"
  #ORIGTIMESTAMP4FFMPEG=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d %H%M%S')
}

processFile2() 
{
  FBNAME=$(basename "${1}")
  echo FBNAME=$FBNAME
  FBNAME_NOEXTENSION="${FBNAME%.*}"
  IFS='_'
  read -a splitarr <<< "$FBNAME_NOEXTENSION"
  echo ${splitarr[-1]}
  unset IFS  

}

processFile() 
{
  FBNAME=$(basename "${1}")
  echo FBNAME=$FBNAME
  FBNAME_NOEXTENSION="${FBNAME%.*}"
  IFS='_'
  read -a splitarr <<< "$FBNAME_NOEXTENSION"
  OUTPUTNAME="${splitarr[-1]}"
  #echo "$FBNAME_NOEXTENSION => OUTPUTNAME="${OUTPUTNAME}""
  unset IFS

  getTimestamps "${1}"

  OUTPUTEXTENSION="mkv"
  OUTPUTFILENAME="${VIDEO_DIR}/output/${ORIGTIMESTAMP4FILENAME}_${OUTPUTNAME}.${OUTPUTEXTENSION}"
  echo $OUTPUTFILENAME
  if [ -f "${OUTPUTFILENAME}" ]; then
    rm -f "${OUTPUTFILENAME}"
  fi  

  cmd="ffmpeg -i \"${1}\" \
              -metadata title=\"${OUTPUTNAME}\" \
              -metadata date=${ORIGTIMESTAMP} \
              -metadata creation_time=\"${ORIGTIMESTAMP_ISO8601}\" \
              -codec copy -map 0 \
              -avoid_negative_ts 1 \
              \"${OUTPUTFILENAME}\" " 
  echo $cmd
  eval $cmd
  touch -d @${ORIGTIMESTAMP_UNIX} "${OUTPUTFILENAME}"
  mediainfo "${OUTPUTFILENAME}"
  ls -l "${OUTPUTFILENAME}"
}

# main
VIDEO_DIR=${VIDEO_DIR:-/links/FamilienVideos-ssd/temp}
LIST_FILE=${VIDEO_DIR}/videos.lst
rm ${LIST_FILE}
find ${VIDEO_DIR}/input -type f -printf  "%p\n"  | sort >> ${LIST_FILE} 
#find ${VIDEO_DIR}/input -type f -printf  "file '%p'\n"  | sort >> ${LIST_FILE}
#find ${VIDEO_DIR}/input -type f -printf "%T+\t%p\n" | sort | awk '{$1=""; print substr($0,2)}' | xargs -I % echo file \'%\' >> ${LIST_FILE} 

while read -u 10 CURFILE
do
  echo "---------------------------------------------------------------------"
  echo "Processing $CURFILE"
  processFile "$CURFILE"
done 10<"${LIST_FILE}"


#exiftool -s -time:all "${OUTPUTFILENAME}"

### old use exiftool
# DATETAGS=(CreateDate ModifyDate TrackCreateDate TrackModifyDate MediaCreateDate MediaModifyDate)
# for t in "${DATETAGS[@]}"; do
#     exiftool -overwrite_original -tagsFromFile ${FIRSTFILENAME} -${t} "${OUTPUTFILENAME}"
# done    

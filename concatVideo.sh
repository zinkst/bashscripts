#!/bin/bash
# This command takes all videos in VIDEO_DIR/input and does
# * merges all videos into one video uning ffmepg
# * it writes the timestamp of the first video file to the generated output file
# * generates an outputfilename based on input parameter and timestamp of first input file

getTimestamps()
{
  FBNAME=$(basename "$FIRSTFILENAME")
  EXTENSION="${FBNAME##*.}"
  echo ${EXTENSION}
  if [ "${EXTENSION}" == "MTS" ]; then
	TIMESTAMP=$(mediainfo --Inform="General;%Recorded_Date%" "$FIRSTFILENAME")
  else 
	TIMESTAMP=$(mediainfo --Inform="Video;%Encoded_Date%" "$FIRSTFILENAME")
	#TIMESTAMP="UTC 2013-05-24 19:35:22"
  	TIMESTAMP=${TIMESTAMP:4}
  fi	
  
  ## hardcode timestamp if not available
  echo "MEDIATIMESTAMP=$TIMESTAMP" # UTC 2020-01-18 13:27:09
  ORIGTIMESTAMP_UNIX_UTC=$(TZ=UTC date +'%s' -d "${TIMESTAMP}")
  echo "ORIGTIMESTAMP_UNIX_UTC=${ORIGTIMESTAMP_UNIX_UTC}"
  ORIGTIMESTAMP_UNIX=$(TZ="Europe/Berlin" date +'%s' -d@"${ORIGTIMESTAMP_UNIX_UTC}")
  #echo "ORIGTIMESTAMP_UNIX=${ORIGTIMESTAMP_UNIX}"
  ORIGTIMESTAMP_ISO8601=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%dT%H%M%S')
  #echo "ORIGTIMESTAMP_ISO8601=${ORIGTIMESTAMP_ISO8601}"
  if [[ $FBNAME=="VID_*" ]]; then
    FBNAME="${FBNAME:4}"
  fi	
  #ORIGTIMESTAMP_UNIX=`stat -c %Y "${FIRSTFILENAME}"`
  ORIGTIMESTAMP=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d_%H%M%S')
  ORIGTIMESTAMP4FILENAME=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%m%d')
  echo "ORIGTIMESTAMP=${ORIGTIMESTAMP}"
  #ORIGTIMESTAMP4FFMPEG=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d %H%M%S')
}


VIDEO_DIR=${VIDEO_DIR:-/links/FamilienVideos-ssd/temp}
LIST_FILE=${VIDEO_DIR}/videos.lst
rm ${LIST_FILE}
find ${VIDEO_DIR}/input -type f -printf  "file '%p'\n"  | sort >> ${LIST_FILE}
FIRSTFILENAME=$(find ${VIDEO_DIR}/input -type f -print -quit)

if [ -z $1 ]; then
  FBNAME=$(basename "$FIRSTFILENAME")
  FBNAME_NOEXTENSION="${FBNAME%.*}"
  IFS='_'
  read -a splitarr <<< "$FBNAME_NOEXTENSION"
  OUTPUTNAME="${splitarr[-1]}"
  #echo "$FBNAME_NOEXTENSION => OUTPUTNAME="${OUTPUTNAME}""
  unset IFS
else
  OUTPUTNAME=$1
fi  


getTimestamps

OUTPUTEXTENSION="mkv"
OUTPUTFILENAME="${VIDEO_DIR}/output/${ORIGTIMESTAMP4FILENAME}_${OUTPUTNAME}.${OUTPUTEXTENSION}"
echo $OUTPUTFILENAME
if [ -f "${OUTPUTFILENAME}" ]; then
  rm -f "${OUTPUTFILENAME}"
fi  


# cmd="ffmpeg -i \"${FIRSTFILENAME}\"  
#             -metadata title=\"${OUTPUTNAME}\" \
#             -metadata date=${ORIGTIMESTAMP} \
#             -metadata creation_time=\"${ORIGTIMESTAMP_ISO8601}\" \
#             -codec copy -map 0 \
#             -avoid_negative_ts 1 \
#             \"${OUTPUTFILENAME}\" " 

cmd="ffmpeg -f concat \
            -safe 0 \
            -i ${LIST_FILE} \
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
#exiftool -s -time:all "${OUTPUTFILENAME}"

### old use exiftool
# DATETAGS=(CreateDate ModifyDate TrackCreateDate TrackModifyDate MediaCreateDate MediaModifyDate)
# for t in "${DATETAGS[@]}"; do
#     exiftool -overwrite_original -tagsFromFile ${FIRSTFILENAME} -${t} "${OUTPUTFILENAME}"
# done    

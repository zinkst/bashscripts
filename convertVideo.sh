#!/bin/bash
# This command takes all videos in VIDEO_DIR/input and does
# * merges all videos into one video uning ffmepg
# * it writes the timestamp of the first video file to the generated output file
# * generates an outputfilename based on input parameter and timestamp of first input file

getTimestamps()
{
  TIMESTAMP=$(mediainfo --Inform="Video;%Encoded_Date%" $FIRSTFILENAME)
  echo "MEDIATIMESTAMP=$TIMESTAMP" # UTC 2020-01-18 13:27:09
  #echo ${TIMESTAMP:4}
  ORIGTIMESTAMP_UNIX_UTC=$(TZ=UTC date +'%s' -d "${TIMESTAMP:4}")
  #echo "ORIGTIMESTAMP_UNIX_UTC=${ORIGTIMESTAMP_UNIX_UTC}"
  ORIGTIMESTAMP_UNIX=$(TZ="Europe/Berlin" date +'%s' -d@"${ORIGTIMESTAMP_UNIX_UTC}")
  #echo "ORIGTIMESTAMP_UNIX=${ORIGTIMESTAMP_UNIX}"
  ORIGTIMESTAMP_ISO8601=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%dT%H%M%S')
  #echo "ORIGTIMESTAMP_ISO8601=${ORIGTIMESTAMP_ISO8601}"
  FBNAME=$(basename "$FIRSTFILENAME")
  EXTENSION="${FBNAME##*.}"
  echo ${EXTENSION}
  if [[ $FBNAME=="VID_*" ]]; then
    FBNAME="${FBNAME:4}"
  fi	
  #ORIGTIMESTAMP_UNIX=`stat -c %Y "${FIRSTFILENAME}"`
  ORIGTIMESTAMP=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d_%H%M%S')
  echo "ORIGTIMESTAMP=${ORIGTIMESTAMP}"
  #ORIGTIMESTAMP4FFMPEG=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d %H%M%S')
}

OUTPUTNAME=output
if [[ ! -v $1 ]]; then
  OUTPUTNAME=$1
fi  
echo ${OUTPUTNAME}
VIDEO_DIR=${VIDEO_DIR:-/links/FamilienVideos-ssd/temp}
rm ${VIDEO_DIR}/output/videos.lst
find ${VIDEO_DIR}/input -type f -printf  "file '%p'\n"  | sort >> ${VIDEO_DIR}/output/videos.lst 
#find ${VIDEO_DIR}/input -type f -printf "%T+\t%p\n" | sort | awk '{$1=""; print substr($0,2)}' | xargs -I % echo file \'%\' >> ${VIDEO_DIR}/output/videos.lst 
FIRSTFILENAME=$(find ${VIDEO_DIR}/input -type f -print -quit)
getTimestamps

OUTPUTFILENAME=${VIDEO_DIR}/output/${ORIGTIMESTAMP}_${OUTPUTNAME}.${EXTENSION}
if [ -f "${OUTPUTFILENAME}" ]; then
  rm -f "${OUTPUTFILENAME}"
fi  

cmd="ffmpeg -f concat \
            -safe 0 \
            -i ${VIDEO_DIR}/output/videos.lst \
            -c copy \
            -metadata title=\"${OUTPUTNAME}\" \
            -metadata date=${ORIGTIMESTAMP} \
            -metadata creation_time=\"${ORIGTIMESTAMP_ISO8601}\" \
            \"${OUTPUTFILENAME}\"" 
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

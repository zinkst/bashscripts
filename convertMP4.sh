#!/bin/bash
# This command takes all videos in VIDEO_DIR/input and does
# * merges all videos into one video uning ffmepg
# * it writes the timestamp of the first video file to the generated output file
# * generates an outputfilename based on input parameter and timestamp of first input file
VIDEO_DIR=/links/FamilienVideos/temp/
OUTPUTNAME=output
if [[ ! -v $1 ]]; then
  OUTPUTNAME=$1
fi  
echo ${OUTPUTNAME}
rm ${VIDEO_DIR}/output/videos.lst
FIRSTFILENAME=$(find ${VIDEO_DIR}/input -type f -print -quit)
find ${VIDEO_DIR}/input -type f -printf "%T+\t%p\n" | sort | awk '{print $2}' | xargs -I % echo file % >> ${VIDEO_DIR}/output/videos.lst 
ORIGTIMESTAMP_UNIX=`stat -c %Y ${FIRSTFILENAME}`
ORIGTIMESTAMP=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d_%H%M%S')
#ORIGTIMESTAMP4FFMPEG=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d %H%M%S')
ORIGTIMESTAMP4ISO8601=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%dT%H%M%S')
OUTPUTFILENAME=${VIDEO_DIR}output/${ORIGTIMESTAMP}_${OUTPUTNAME}.mp4
if [ -f "${OUTPUTFILENAME}" ]; then
  rm -f "${OUTPUTFILENAME}"
fi  

ffmpeg -f concat \
       -safe 0 \
       -i ${VIDEO_DIR}/output/videos.lst \
       -c copy \
       -metadata title="${OUTPUTNAME}" \
       -metadata date=${ORIGTIMESTAMP} \
       -metadata creation_time="${ORIGTIMESTAMP4ISO8601}" \
       "${OUTPUTFILENAME}" 

touch -d @${ORIGTIMESTAMP_UNIX} "${OUTPUTFILENAME}"
mediainfo "${OUTPUTFILENAME}"
ls -l "${OUTPUTFILENAME}"
exiftool -s -time:all "${OUTPUTFILENAME}"

### old use exiftool
# DATETAGS=(CreateDate ModifyDate TrackCreateDate TrackModifyDate MediaCreateDate MediaModifyDate)
# for t in "${DATETAGS[@]}"; do
#     exiftool -overwrite_original -tagsFromFile ${FIRSTFILENAME} -${t} "${OUTPUTFILENAME}"
# done    

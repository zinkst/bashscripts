#!/bin/bash
# This command takes all videos in VIDEO_DIR/input and does
# * merges all videos into one video uning ffmepg
# * it writes the timestamp of the first video file to the generated output file
# * generates an outputfilename based on input parameter and timestamp of first input file

source /links/bin/video_functions.sh

while getopts "o:n:a:c:" OPTNAME
do
  case "${OPTNAME}" in
    "o")
      OUTPUTEXTENSION=${OPTARG}
      echo "Option ${OPTNAME} is specified OUTPUTEXTENSION=${OUTPUTEXTENSION}"
      ;;
    "n")
      # use this value as title
      OUTPUTNAME=${OPTARG} 
      echo "Option ${OPTNAME} is specified OUTPUTNAME=${OUTPUTNAME}"
      ;;
    "a")
      # append this value to title 
      NAMEAPPENDIX=${OPTARG} 
      echo "Option ${OPTNAME} is specified NAMEAPPENDIX=${NAMEAPPENDIX}"
      ;;
    "c")
      # append this value to title 
      CAMERA=${OPTARG} 
      echo "Option ${OPTNAME} is specified CAMERA=${CAMERA}"
      ;;
  esac
  #echo "OPTIND is now $OPTIND"
done


VIDEO_DIR=${VIDEO_DIR:-/links/FamilienVideos-ssd/temp}
LIST_FILE=${VIDEO_DIR}/videos.lst
rm ${LIST_FILE}
find ${VIDEO_DIR}/input -type f -printf  "file '%p'\n"  | sort >> ${LIST_FILE}
FIRSTFILENAME=$(find ${VIDEO_DIR}/input -type f -print -quit)
FBNAME=$(basename "$FIRSTFILENAME")
EXTENSION="${FBNAME##*.}"

if [ -z "${OUTPUTNAME}"  ]; then
  FBNAME_NOEXTENSION="${FBNAME%.*}"
  IFS='_'
  read -a splitarr <<< "$FBNAME_NOEXTENSION"
  OUTPUTNAME="${splitarr[-1]}"
  unset IFS
fi  

if [ -z ${OUTPUTEXTENSION} ]; then 
   if [ "${EXTENSION}" == "MTS" ]; then
	  OUTPUTEXTENSION="mkv"
  else
    OUTPUTEXTENSION=${EXTENSION}
  fi
fi

getTimestamps "${FIRSTFILENAME}"
getGPSInfo "${FIRSTFILENAME}"
getCamera "${FIRSTFILENAME}"

if [ -z $NAMEAPPENDIX ]; then
  OUTPUTFILENAME="${VIDEO_DIR}/output/${DATESTAMP4FILENAME}_${OUTPUTNAME}_${TIMESTAMP4FILENAME}.${OUTPUTEXTENSION}"
else
  OUTPUTFILENAME="${VIDEO_DIR}/output/${DATESTAMP4FILENAME}_${OUTPUTNAME} ${NAMEAPPENDIX}_${TIMESTAMP4FILENAME}.${OUTPUTEXTENSION}"
fi

echo $OUTPUTFILENAME
if [ -f "${OUTPUTFILENAME}" ]; then
  rm -f "${OUTPUTFILENAME}"
fi  

cmd="ffmpeg -y \
            -loglevel panic \
            -f concat \
            -safe 0 \
            -i ${LIST_FILE} \
            -metadata title=\"${OUTPUTNAME}\" \
            -metadata date=${ORIGTIMESTAMP} \
            -metadata creation_time=\"${ORIGTIMESTAMP_ISO8601}\" \
            -metadata location=\"${GPSCOORDINATES}\" \
            -metadata Make=\"${CAMERA_MANUFACTURER}\" \
            -metadata \"Camera Manufacturer Name\"=\"${CAMERA_MANUFACTURER}\" \
            -metadata \"Camera Model Name\"=\"${CAMERA_MODEL_NAME}\" \
            -codec copy -map 0 \
            -avoid_negative_ts 1 \
            -ignore_unknown \
            -movflags use_metadata_tags \
            \"${OUTPUTFILENAME}\" " 
echo $cmd
valuesSummary
askContinue
eval $cmd

echo touch -d @${ORIGTIMESTAMP_UNIX} "${OUTPUTFILENAME}"
touch -d @${ORIGTIMESTAMP_UNIX} "${OUTPUTFILENAME}"
#mediainfo "${OUTPUTFILENAME}"
ls -l "${OUTPUTFILENAME}"
#exiftool -s -time:all "${OUTPUTFILENAME}"

### old use exiftool
# DATETAGS=(CreateDate ModifyDate TrackCreateDate TrackModifyDate MediaCreateDate MediaModifyDate)
# for t in "${DATETAGS[@]}"; do
#     exiftool -overwrite_original -tagsFromFile ${FIRSTFILENAME} -${t} "${OUTPUTFILENAME}"
# done    

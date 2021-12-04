#!/bin/bash
# This command takes all videos in VIDEO_DIR/input and does
# * merges all videos into one video uning ffmepg
# * it writes the timestamp of the first video file to the generated output file
# * generates an outputfilename based on input parameter and timestamp of first input file

source /links/bin/video_functions.sh

function usage() {
  echo "-o extension of video e.g.  mkv"
  echo "-n \"Title of Video\""
  echo "-a \"Appendix fo title\""
  echo "-c \"Manufacturer of camera\""
}


declare -A CONFIG

if [[ $1 == "" ]]; then
   usage;
    exit;
else
  while getopts "o:n:a:c:t" OPTNAME
  do
    case "${OPTNAME}" in
      "o")
        CONFIG[OUTPUTEXTENSION]=${OPTARG}
        echo "Option ${OPTNAME} is specified CONFIG[OUTPUTEXTENSION]=${CONFIG[OUTPUTEXTENSION]}"
        ;;
      "n")
        # use this value as title
        CONFIG[OUTPUTNAME]=${OPTARG} 
        echo "Option ${OPTNAME} is specified CONFIG[OUTPUTNAME]=${CONFIG[OUTPUTNAME]}"
        ;;
      "a")
        # append this value to title 
        CONFIG[NAMEAPPENDIX]=${OPTARG} 
        echo "Option ${OPTNAME} is specified CONFIG[NAMEAPPENDIX]=${CONFIG[NAMEAPPENDIX]}"
        ;;
      "c")
        # append this value to title 
        CONFIG[CAMERA]=${OPTARG} 
        echo "Option ${OPTNAME} is specified CONFIG[CAMERA]=${CONFIG[CAMERA]}"
        ;;
      "t")
        CONFIG[TIMESTAMP_METHOD]="FileNamePrefix" 
        echo "Option ${OPTNAME} is specified TIMESTAMP_METHOD=\"${CONFIG[TIMESTAMP_METHOD]}\""
        ;;  
    esac
    #echo "OPTIND is now $OPTIND"
  done
fi

VIDEO_DIR=${VIDEO_DIR:-/links/FamilienVideos-ssd/temp}
LIST_FILE=${VIDEO_DIR}/videos.lst
rm ${LIST_FILE}
find ${VIDEO_DIR}/input -type f -printf  "file '%p'\n"  | sort >> ${LIST_FILE}
FIRSTFILENAME=$(find ${VIDEO_DIR}/input -type f -print -quit)
FBNAME=$(basename "$FIRSTFILENAME")
EXTENSION="${FBNAME##*.}"
FBNAME_NOEXTENSION="${FBNAME%.*}"

verifyOutputExtension "${FIRSTFILENAME}"
getVideoTitle "${FIRSTFILENAME}"
if [ "${CONFIG[TIMESTAMP_METHOD]}" == "" ];
then  
  getTimestamps "${FIRSTFILENAME}"
else
  getTimestampsFromFilename "${FIRSTFILENAME}"
fi    
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
            -noautorotate \
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
# cmd="ffmpeg -i \"${FIRSTFILENAME}\" \
#             -metadata title=\"${OUTPUTNAME}\" \
#             -metadata date=${ORIGTIMESTAMP} \
#             -metadata creation_time=\"${ORIGTIMESTAMP_ISO8601}\" \
#             \"${OUTPUTFILENAME}\" " 
echo $cmd
valuesSummary
askContinue
eval $cmd

echo touch -d @${ORIGTIMESTAMP_UNIX} "${OUTPUTFILENAME}"
touch -d @${ORIGTIMESTAMP_UNIX} "${OUTPUTFILENAME}"
ls -l "${OUTPUTFILENAME}"
displayVideoInfo "${OUTPUTFILENAME}"
#exiftool -s -time:all "${OUTPUTFILENAME}"

### old use exiftool
# DATETAGS=(CreateDate ModifyDate TrackCreateDate TrackModifyDate MediaCreateDate MediaModifyDate)
# for t in "${DATETAGS[@]}"; do
#     exiftool -overwrite_original -tagsFromFile ${FIRSTFILENAME} -${t} "${OUTPUTFILENAME}"
# done    

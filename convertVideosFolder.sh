#!/bin/bash
# This command takes all videos in VIDEO_DIR/input and does
# * merges all videos into one video uning ffmepg
# * it writes the timestamp of the first video file to the generated output file
# * generates an outputfilename based on input parameter and timestamp of first input file

source /links/bin/video_functions.sh

# getTimestamps()
# {
#   if [ "${EXTENSION}" == "MTS" ]; then
# 	  TIMESTAMP=$(mediainfo --Inform="General;%Recorded_Date%" "${1}")
#   else 
# 	  TIMESTAMP=$(mediainfo --Inform="Video;%Encoded_Date%" "${1}")
# 	  ## hardcode timestamp if not available
#     #TIMESTAMP="UTC 2013-05-24 19:35:22"
#   	TIMESTAMP=${TIMESTAMP:4}
#   fi	
  
#   echo "MEDIATIMESTAMP=$TIMESTAMP" # UTC 2020-01-18 13:27:09
#   ORIGTIMESTAMP_UNIX_UTC=$(TZ=UTC date +'%s' -d "${TIMESTAMP}")
#   echo "ORIGTIMESTAMP_UNIX_UTC=${ORIGTIMESTAMP_UNIX_UTC}"
#   ORIGTIMESTAMP_UNIX=$(TZ="Europe/Berlin" date +'%s' -d@"${ORIGTIMESTAMP_UNIX_UTC}")
#   #echo "ORIGTIMESTAMP_UNIX=${ORIGTIMESTAMP_UNIX}"
#   ORIGTIMESTAMP_ISO8601=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%dT%H%M%S')
#   #echo "ORIGTIMESTAMP_ISO8601=${ORIGTIMESTAMP_ISO8601}"
#   #ORIGTIMESTAMP_UNIX=`stat -c %Y "${1}"`
#   ORIGTIMESTAMP=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d_%H%M%S')
#   DATESTAMP4FILENAME=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%m%d')
#   TIMETAMP4FILENAME=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%H%M')
#   echo "ORIGTIMESTAMP=${ORIGTIMESTAMP}"
#   #ORIGTIMESTAMP4FFMPEG=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d %H%M%S')
# }

processFile() 
{
  FBNAME=$(basename "${1}")
  echo FBNAME=$FBNAME
  FBNAME_NOEXTENSION="${FBNAME%.*}"
  EXTENSION="${FBNAME##*.}"
  #echo "EXTENSION=${EXTENSION}"
  
  resetValuesToConfig
  verifyOutputExtension "${1}"
  getVideoTitle "${1}"
  getTimestamps "${1}"
  getGPSInfo "${1}"
  getCamera "${1}"

  #temp fix new files already concatenated but not renamed
  if [ "${TITLE}" == "" ];
  then
    #TITLE was not set, we need to compute filename
    if [ $ADD_INDEX_TO_FILENAME ]; then
      OUTPUTFILENAME="${VIDEO_DIR}/output/${DATESTAMP4FILENAME}_${PADDEDINDEX}_${OUTPUTNAME}_${TIMESTAMP4FILENAME}.${OUTPUTEXTENSION}"
    else
      OUTPUTFILENAME="${VIDEO_DIR}/output/${DATESTAMP4FILENAME}_${OUTPUTNAME}_${TIMESTAMP4FILENAME}.${OUTPUTEXTENSION}"
    fi
  else
    # Title was already set use original filename 
    echo FBNAME=$FBNAME
    OUTPUTFILENAME="${VIDEO_DIR}/output/${FBNAME_NOEXTENSION}.${OUTPUTEXTENSION}"  
  fi
  if $SKIP ; 
  then
    cmd="cp -p \"${1}\" \"${OUTPUTFILENAME}\""
    echo "Skipping Conversion copying File:" $cmd
    eval $cmd
  else
    cmd="ffmpeg -loglevel panic -y \
                -i \"${1}\" \
                -metadata title=\"${OUTPUTNAME}\" \
                -metadata date=${ORIGTIMESTAMP} \
                -metadata creation_time=\"${ORIGTIMESTAMP_ISO8601}\" \
                -metadata Make=\"${CAMERA_MANUFACTURER}\" \
                -metadata \"Camera Manufacturer Name\"=\"${CAMERA_MANUFACTURER}\" \
                -metadata \"Camera Model Name\"=\"${CAMERA_MODEL_NAME}\" \
                -metadata location=\"${GPSCOORDINATES}\" \
                -codec copy -map 0 \
                -avoid_negative_ts 1 \
                -ignore_unknown \
                -movflags use_metadata_tags \
                \"${OUTPUTFILENAME}\" " 
    echo $cmd
    valuesSummary
    askContinue
    eval $cmd
    touch -d @${ORIGTIMESTAMP_UNIX} "${OUTPUTFILENAME}"
  fi  
  displayVideoInfo "${OUTPUTFILENAME}"
  ls -l "${OUTPUTFILENAME}"
}

function usage() {
  echo "-o extension of video e.g.  mkv"
  echo "-n \"Title of Video\""
  echo "-i \"Add Padding to Filename\""
  echo "-c \"Manufacturer of camera\""
  echo "-s \"Source directoy: default:${VIDEO_DIR}/temp/input\""
}


# main
declare -A CONFIG

if [[ $1 == "" ]]; then
   usage;
    exit;
else
  while getopts "i:o:c:n:s:" OPTNAME
  do
    case "${OPTNAME}" in
      "i")
        CONFIG[ADD_INDEX_TO_FILENAME]=true
        PADDING=${OPTARG}
        ;;
      "o")
        CONFIG[OUTPUTEXTENSION]=${OPTARG}
        echo "Option ${OPTNAME} is specified OUTPUTEXTENSION=${CONFIG[OUTPUTEXTENSION]}"
        ;;
      "c")
        # append this value to title 
        CONFIG[CAMERA]=${OPTARG} 
        echo "Option ${OPTNAME} is specified CAMERA=${CONFIG[CAMERA]}"
        ;;
      "n")
        # use this value as title
        CONFIG[OUTPUTNAME]=${OPTARG} 
        echo "Option ${OPTNAME} is specified OUTPUTNAME=${CONFIG[OUTPUTNAME]}"
        ;;
      "s")
        CONFIG[SRCDIR]=${OPTARG} 
        echo "Option ${OPTNAME} is specified SRCDIR=${CONFIG[SRCDIR]}"
        ;;
    esac
    #echo "OPTIND is now $OPTIND"
  done
fi

VIDEO_DIR=${VIDEO_DIR:-/links/FamilienVideos-ssd/temp}
LIST_FILE=${VIDEO_DIR}/videos.lst
rm ${LIST_FILE}
if [ "${CONFIG[SRCDIR]}" == "" ];
then
  find ${VIDEO_DIR}/input -type f -printf  "%p\n"  | sort >> ${LIST_FILE} 
else
  find ${CONFIG[SRCDIR]} -type f -printf  "%p\n"  | sort >> ${LIST_FILE} 
fi
#find ${VIDEO_DIR}/input -type f -printf  "file '%p'\n"  | sort >> ${LIST_FILE}
#find ${VIDEO_DIR}/input -type f -printf "%T+\t%p\n" | sort | awk '{$1=""; print substr($0,2)}' | xargs -I % echo file \'%\' >> ${LIST_FILE} 


index=1
while read -u 10 CURFILE
do
  echo "---------------------------------------------------------------------"
  echo "Processing $CURFILE"
  printf -v PADDEDINDEX "%0${PADDING}d" $index
  processFile "$CURFILE"
  ((index++))
  #echo PADDEDINDEX=$PADDEDINDEX
done 10<"${LIST_FILE}"


#exiftool -s -time:all "${OUTPUTFILENAME}"

### old use exiftool
# DATETAGS=(CreateDate ModifyDate TrackCreateDate TrackModifyDate MediaCreateDate MediaModifyDate)
# for t in "${DATETAGS[@]}"; do
#     exiftool -overwrite_original -tagsFromFile ${FIRSTFILENAME} -${t} "${OUTPUTFILENAME}"
# done    

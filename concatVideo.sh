#!/bin/bash
# This command takes all videos in VIDEO_DIR/input and does
# * merges all videos into one video uning ffmepg
# * it writes the timestamp of the first video file to the generated output file
# * generates an outputfilename based on input parameter and timestamp of first input file

getTimestamps()
{
  if [ "${EXTENSION}" == "MTS" ]; then
	  TIMESTAMP=$(mediainfo --Inform="General;%Recorded_Date%" "$FIRSTFILENAME")
  else 
	  TIMESTAMP=$(mediainfo --Inform="Video;%Encoded_Date%" "$FIRSTFILENAME")
  	TIMESTAMP=${TIMESTAMP:4}
  fi
  if [ "${TIMESTAMP}" == "" ]; then
    TIMESTAMP_UNIX=`stat -c %Y "${FIRSTFILENAME}"`
    TIMESTAMP=$(date -d@"${TIMESTAMP_UNIX}" +'%Y-%m-%d %H:%M:%S')
  fi 
  # uncomment and adapt the following to overwrite timestamp
  #TIMESTAMP="UTC 2019-12-28 10:54:00"
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
  ORIGTIMESTAMP=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d_%H%M%S')
  DATESTAMP4FILENAME=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%m%d')
  TIMESTAMP4FILENAME=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%H%M')
  #echo "ORIGTIMESTAMP=${ORIGTIMESTAMP}"
  #ORIGTIMESTAMP4FFMPEG=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d %H%M%S')
}


VIDEO_DIR=${VIDEO_DIR:-/links/FamilienVideos-ssd/temp}
LIST_FILE=${VIDEO_DIR}/videos.lst
rm ${LIST_FILE}
find ${VIDEO_DIR}/input -type f -printf  "file '%p'\n"  | sort >> ${LIST_FILE}
FIRSTFILENAME=$(find ${VIDEO_DIR}/input -type f -print -quit)

while getopts "o:n:a:" OPTNAME
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
  esac
  #echo "OPTIND is now $OPTIND"
done
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

getTimestamps

if [ -z $NAMEAPPENDIX ]; then
  OUTPUTFILENAME="${VIDEO_DIR}/output/${DATESTAMP4FILENAME}_${OUTPUTNAME}_${TIMESTAMP4FILENAME}.${OUTPUTEXTENSION}"
else
  OUTPUTFILENAME="${VIDEO_DIR}/output/${DATESTAMP4FILENAME}_${OUTPUTNAME} ${NAMEAPPENDIX}_${TIMESTAMP4FILENAME}.${OUTPUTEXTENSION}"
fi

echo $OUTPUTFILENAME
if [ -f "${OUTPUTFILENAME}" ]; then
  rm -f "${OUTPUTFILENAME}"
fi  

cmd="ffmpeg -f concat \
            -safe 0 \
            -i ${LIST_FILE} \
            -metadata title=\"${OUTPUTNAME}\" \
            -metadata date=${ORIGTIMESTAMP} \
            -metadata creation_time=\"${ORIGTIMESTAMP_ISO8601}\" \
            -codec copy -map 0 \
            -avoid_negative_ts 1 \
            -ignore_unknown \
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

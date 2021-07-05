#!/bin/bash
getTimestamps()
{
  if [ "${EXTENSION}" == "MTS" ]; then
	  TIMESTAMP=$(mediainfo --Inform="General;%Recorded_Date%" "${1}")
  else 
	  TIMESTAMP=$(mediainfo --Inform="Video;%Encoded_Date%" "${1}")
  	TIMESTAMP=${TIMESTAMP:4}
  fi
  if [ "${TIMESTAMP}" == "" ]; then
    TIMESTAMP_UNIX=`stat -c %Y "${1}"`
    TIMESTAMP=$(date -d@"${TIMESTAMP_UNIX}" +'%Y-%m-%d %H:%M:%S')
  fi 
  # uncomment and adapt the following to overwrite timestamp
  # TIMESTAMP="UTC 2021-06-15 09:52:00"
  setTimestampVariables  
}

getTimestampsFromFilename()
{
  IFS='_'
  read -a splitarr <<< "$FBNAME_NOEXTENSION"
  if [ "$splitarr" == "" ]; then
      echo "WARNING timestamp of Video could not be determined"
   else  
      TIMESTAMP="${splitarr[0]}"
   fi  
   unset IFS
   setTimestampVariables
}


setTimestampVariables() 
{
  echo TIMESTAMP=$TIMESTAMP
  if [ "${TIMESTAMP}" == "" ]; then
    echo "no timestamp found .. exiting"
    exit 1 
  else
    :
    #echo "MEDIATIMESTAMP=$TIMESTAMP" # UTC 2020-01-18 13:27:09
  fi
  ORIGTIMESTAMP_UNIX_UTC=$(TZ=UTC date +'%s' -d "${TIMESTAMP}")
  #echo "ORIGTIMESTAMP_UNIX_UTC=${ORIGTIMESTAMP_UNIX_UTC}"
  ORIGTIMESTAMP_UNIX=$(TZ="Europe/Berlin" date +'%s' -d@"${ORIGTIMESTAMP_UNIX_UTC}")
  #echo "ORIGTIMESTAMP_UNIX=${ORIGTIMESTAMP_UNIX}"
  ORIGTIMESTAMP_ISO8601=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%dT%H%M%S')
  #echo "ORIGTIMESTAMP_ISO8601=${ORIGTIMESTAMP_ISO8601}"
  if [[ "$FBNAME" =~ ^VID_* ]]; then
    FBNAME="${FBNAME:4}"
  fi
  ORIGTIMESTAMP=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d_%H%M%S')
  DATESTAMP4FILENAME=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%m%d')
  TIMESTAMP4FILENAME=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%H%M')
  #echo "ORIGTIMESTAMP=${ORIGTIMESTAMP}"
  ORIGTIMESTAMP4FFMPEG=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d %H%M%S')
}

function getGPSInfo(){
  GPSCOORDINATES_EXIF=$(exiftool -n -p '$GPSLatitude,$GPSLongitude' "${1}")
  #echo GPSCOORDINATES_EXIF=$GPSCOORDINATES_EXIF
  GPSCOORDINATES_FFPROBE=$(ffprobe -v quiet -print_format json -show_format -i "${1}" | jq -r '.format.tags.location')
  GPSCOORDINATES_FFPROBE=${GPSCOORDINATES_FFPROBE::-1}
  #echo GPSCOORDINATES_FFPROBE=$GPSCOORDINATES_FFPROBE 
#  if [[ ${GPSCOORDINATES_FFPROBE} == "nul" && "${CONFIG[TIMESTAMP_METHOD]}" != "" ]];
  if [[ ${GPSCOORDINATES_FFPROBE} == "nul" ]];
  then 
    # hardcode to Burghalde if nothing is found we're processing wiles wthout metadata
    GPSCOORDINATES="+48.6217+008.7801"
  else  
    GPSCOORDINATES=${GPSCOORDINATES_FFPROBE}
  fi  
}

function getCamera() {
  CAMERA_MANUFACTURER=$(exiftool -make -s -s -s "${1}")
  CAMERA_MODEL_NAME=$(exiftool -CameraModelName -s -s -s "${1}")
  if [ "${CAMERA_MODEL_NAME}" == "" ];
  then
    CAMERA_MANUFACTURER=$(exiftool -ComAndroidManufacturer -s -s -s "${1}")
    CAMERA_MODEL_NAME=$(exiftool -ComAndroidModel -s -s -s "${1}")
    if [ "${CAMERA_MODEL_NAME}" == "" ];
    then
      case ${CONFIG[CAMERA]} in
          s9 )
              CAMERA_MANUFACTURER="Samsung"
              CAMERA_MODEL_NAME="Galaxy S9"
              ;;
          s9+ )
              CAMERA_MANUFACTURER="Samsung"
              CAMERA_MODEL_NAME="Galaxy S9+"
              ;;
          xcover )
              CAMERA_MANUFACTURER="Samsung"
              CAMERA_MODEL_NAME="Galaxy XCover Pro"
              ;;
          sony )
              CAMERA_MANUFACTURER="Sony"
              CAMERA_MODEL_NAME="DSC RX-100"
              ;;
          note4 )
              CAMERA_MANUFACTURER="Samsung"
              CAMERA_MODEL_NAME="Galaxy Note 4"
              ;;
          s5 )
              CAMERA_MANUFACTURER="Samsung"
              CAMERA_MODEL_NAME="Galaxy S5"
              ;;
          m30s )
              CAMERA_MANUFACTURER="Samsung"
              CAMERA_MODEL_NAME="Galaxy M30s"
              ;;
          gopro )
              CAMERA_MANUFACTURER="GoPro"
              CAMERA_MODEL_NAME="Hero 3"
              ;;
          eos )
              CAMERA_MANUFACTURER="Canon"
              CAMERA_MODEL_NAME="EOS500D"
              ;;
          super8 )
              CAMERA_MANUFACTURER="Kamera"
              CAMERA_MODEL_NAME="super8"
              ;;
          minidv )
              CAMERA_MANUFACTURER="Camcorder"
              CAMERA_MODEL_NAME="MiniDV"
              ;;
          whatsapp )
              CAMERA_MANUFACTURER="Messenger"
              CAMERA_MODEL_NAME="Whatsapp"
              ;;
          apple )
              CAMERA_MANUFACTURER="Apple"
              CAMERA_MODEL_NAME="iPhone"
              ;;
      esac
    fi  
  fi 
}

function askContinue() { 
  read -p "Are you sure? " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Nn]$ ]]
  then
      echo "$REPLY > exiting"
      exit 0
  fi
} 

function getVideoTitle() {
  if [[ "${CONFIG[OUTPUTNAME]}" == "" ]]; then
    TITLE=$(exiftool -Title -s -s -s "${1}")
    if [ "${TITLE}" == "" ];
    then
      IFS='_'
      read -a splitarr <<< "$FBNAME_NOEXTENSION"
      if [ "$splitarr" == "" ]; then
        echo "WARNING title of Video could not be determined"
      else  
        OUTPUTNAME="${splitarr[-1]}"
      fi  
      unset IFS
    else
      OUTPUTNAME=$TITLE
    fi
  else
    OUTPUTNAME=${CONFIG[OUTPUTNAME]}
  fi
}



function valuesSummary() {
  echo CAMERA_MODEL_NAME=$CAMERA_MODEL_NAME
  echo CAMERA_MANUFACTURER=$CAMERA_MANUFACTURER
  echo GPSCOORDINATES=$GPSCOORDINATES     
  echo OUTPUTFILENAME=${OUTPUTFILENAME}
  echo OUTPUTNAME=${OUTPUTNAME}
  echo ORIGTIMESTAMP=${ORIGTIMESTAMP}
}

function displayVideoInfo() {
  # get all known parameters
  # mediainfo --Info-Parameters
  mediainfo --Inform="General;%LOCATION% : %CAMERA_MODEL_NAME% : %CAMERA_MANUFACTURER_NAME% : %DATE% : %Movie% : %Encoded_Date%" "${1}"
  # mediainfo --Inform="General;%CAMERA_MODEL_NAME%" "${1}"
  mediainfo --Inform="Video;%Width%x%Height% : %Rotation%" "${1}"
  # mediainfo --Inform="Video;%Rotation%" "${1}"
}

function verifyOutputExtension() {
  SKIP=false
  if [[ "${EXTENSION}" == "mkv" ]]; then 
    SKIP=true
  elif [ "${CONFIG[OUTPUTEXTENSION]}" == "" ]; then 
    if [ "${EXTENSION}" == "MTS" ]; then
      OUTPUTEXTENSION="mkv"
    else
      OUTPUTEXTENSION=${EXTENSION}
    fi
  else
    OUTPUTEXTENSION=${CONFIG[OUTPUTEXTENSION]}
  fi  
  # most videoplayers do not autorotate based on Rotation flag when output format is not mp4
  # https://stackoverflow.com/questions/54878068/ffmpeg-auto-rotates-video-when-only-copying-stream
  # 0.000 or 90.000
  ROTATION=$(mediainfo --Inform="Video;%Rotation%" "${1}")
  if [[ "$ROTATION" != "0.000" && "$ROTATION" != "" ]]
  then
    echo "Video is rotated overwriting OUTPUTEXTENSION to mp4" 
    OUTPUTEXTENSION="mp4"
    SKIP=true
  fi
  echo "SKIP=$SKIP ; OUTPUTEXTENSION=$OUTPUTEXTENSION" 
}

function printInfoIfRotated() {
  ROTATION=$(mediainfo --Inform="Video;%Rotation%" "${1}")
  if [ "$ROTATION" != "0.000" ]
  then
    echo "Rotation: ${ROTATION}: ${1}"
  fi  
}

function setStreamCopyOption() {
  case ${EXTENSION} in
    mpg )
        STREAM_COPY_OPTION="c:v libx264 -preset slow -crf 13 -c:a copy"  # mp2 to mkv (x264)
        ;;
    m4v )
        STREAM_COPY_OPTION="c:v copy -c:a copy"  # m4v to mkv
        ;;
    *)
        STREAM_COPY_OPTION="codec copy -map 0"  # mp4 to mkv
  esac
  echo "STREAM_COPY_OPTION:$STREAM_COPY_OPTION" 
}


function resetValuesToConfig() {
  OUTPUTEXTENSION=${CONFIG[OUTPUTEXTENSION]}
  CAMERA=${CONFIG[CAMERA]}
  OUTPUTNAME=${CONFIG[OUTPUTNAME]}
}
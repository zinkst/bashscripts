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
    #TIMESTAMP="UTC 2019-12-28 10:54:00"
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
  #ORIGTIMESTAMP4FFMPEG=$(date -d@"${ORIGTIMESTAMP_UNIX}" +'%Y%m%d %H%M%S')
}

function getGPSInfo(){
  GPSCOORDINATES_EXIF=$(exiftool -n -p '$GPSLatitude,$GPSLongitude' "${1}")
  #echo GPSCOORDINATES_EXIF=$GPSCOORDINATES_EXIF
  GPSCOORDINATES_FFPROBE=$(ffprobe -v quiet -print_format json -show_format -i "${1}" | jq -r '.format.tags.location')
  GPSCOORDINATES_FFPROBE=${GPSCOORDINATES_FFPROBE::-1}
  #echo GPSCOORDINATES_FFPROBE=$GPSCOORDINATES_FFPROBE 
  GPSCOORDINATES=${GPSCOORDINATES_FFPROBE}
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
      case $CAMERA in
          s9 )
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
  if [[ "${OUTPUTNAME}" == "" ]]; then
    TITLE=$(exiftool -Title -s -s -s "${1}")
    if [ "${TITLE}" == "" ];
    then
      IFS='_'
      read -a splitarr <<< "$FBNAME_NOEXTENSION"
      OUTPUTNAME="${splitarr[-1]}"
      #echo "$FBNAME_NOEXTENSION => OUTPUTNAME="${OUTPUTNAME}""
      unset IFS
    else
      OUTPUTNAME=$TITLE
    fi
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
  # mediainfo --Inform="General;%CAMERA_MANUFACTURER_NAME%" "${1}"
  # mediainfo --Inform="General;%DATE%" "${1}"
  # mediainfo --Inform="General;%Movie%" "${1}"
  # mediainfo --Inform="General;%Encoded_Date%" "${1}"
  mediainfo --Inform="Video;%Width%x%Height%" "${1}"
  # mediainfo --Inform="Video;%Width%" "${1}"
  # mediainfo --Inform="Video;%Height%" "${1}"
}
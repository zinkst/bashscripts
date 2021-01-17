#!/bin/bash
source /links/bin/video_functions.sh

cmd="ffmpeg -y \
            -noautorotate \
            -i \"${1}\" \
            -codec copy -map 0 \
            -metadata RATING="${2}"
            -avoid_negative_ts 1 \
            -ignore_unknown \
            -movflags use_metadata_tags \
            \"rated_${1}\" " 
echo $cmd
eval $cmd
diff <(mediainfo "${1}") <(mediainfo "rated_${1}" )
echo RATING=$(mediainfo --Inform="General;%RATING%" "rated_${1}")
  
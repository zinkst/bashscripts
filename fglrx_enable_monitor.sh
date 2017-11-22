#!/bin/bash
echo "script to switch on and off attached monitors"
echo "usage:"
echo "${0}   -> enables Monitors which are currently installed according to aticonfig"
echo "${0} 1 -> enables DVI and Thinkpad TFT"
echo "${0} 2 -> enables Thinkpad TFT"
echo "${0} 3 -> enables SubD and Thinkpad TFT"
CONNECTED_MONITORS=`aticonfig --query-monitor | grep 'Connected monitors:' | awk '{print $3,$4,$5}' | sed 's/ //'`
echo "Monitors = " ${CONNECTED_MONITORS}
if [ -z ${1} ]
then
  echo "enabling DVI and Thinkpad TFT"
  CMD="aticonfig --effective=now --enable-monitor ${CONNECTED_MONITORS}"
  echo ${CMD}
  `${CMD}`
elif [ ${1} = "1" ]  
then
  echo "enabling DVI and Thinkpad TFT"
  aticonfig --effective=now --enable-monitor lvds,tmds1
elif [ ${1} = "2" ] 
then
  echo "enabling Thinkpad TFT"
  aticonfig --effective=now --enable-monitor lvds
elif [ ${1} = "3" ] 
then
  echo "enabling Sub-D and Thinkpad TFT"
  aticonfig --effective=now --enable-monitor lvds,crt1
fi


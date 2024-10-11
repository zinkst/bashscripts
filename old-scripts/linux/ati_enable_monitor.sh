#!/bin/bash
echo "script to switch on and off attached monitors"
echo "usage:"
default="determines all connected monitors and enables them"
opt1="enables Thinkpad TFT return from Dual Screen"
opt2="enables DVI and Thinkpad TFT"
opt3="enables Thinkpad TFT"
opt4="enabling Sub-D and Thinkpad TFT dual screen"
opt5="enables SubD and Thinkpad TFT mirror screen 1024x768" 

echo "${0}   -> ${default}"
echo "${0} 1 -> ${opt1}"
echo "${0} 2 -> ${opt2}"
echo "${0} 3 -> ${opt3}"
echo "${0} 4 -> ${opt4}"
echo "${0} 5 -> ${opt5}" 


PANEL_EXISTS=`xrandr -q | grep 'PANEL' | awk '{print $1}'`
DFP_EXISTS=`xrandr -q | grep 'DFP1' | awk '{print $1}'`
echo "PANEL_EXISTS="${PANEL_EXISTS}
echo "DFP_EXISTS="${DFP_EXISTS}
#if ${PANEL_EXISTS} == "PANEL" 
#then
#  PANEL_EXISTS=awk '{print $PANEL_EXISTS}'
#else
#  PANEL_EXISTS="FALSE"
#fi    
#echo "PANEL_EXISTS="${PANEL_EXISTS}

if [ "PANEL" == ${PANEL_EXISTS} ]
then
  echo "Radeonhd is used"
  PANEL_ID="PANEL"
  DVI_ID="DVI-D_1"
  VGA_ID="VGA_1"
  PANEL_CONNECTED=`xrandr -q | grep 'PANEL' | awk '{print $2}'`
  DVI_CONNECTED=`xrandr -q | grep 'DVI-D_1' | awk '{print $2}'`
  VGA_CONNECTED=`xrandr -q | grep 'VGA_1' | awk '{print $2}'`
elif [ ${DFP_EXISTS} == "DFP1" ]
then
  echo "fglrx is used"
  PANEL_ID="LVDS"
  DVI_ID="DFP1"
  VGA_ID="CRT1"
  PANEL_CONNECTED=`xrandr -q | grep 'LVDS' | awk '{print $2}'`
  DVI_CONNECTED=`xrandr -q | grep 'DFP1' | awk '{print $2}'`
  VGA_CONNECTED=`xrandr -q | grep 'CRT1' | awk '{print $2}'`
else
  echo "Radeon is used"
  PANEL_ID="LVDS"
  DVI_ID="DVI-0"
  VGA_ID="VGA-0"
  PANEL_CONNECTED=`xrandr -q | grep 'LVDS' | awk '{print $2}'`
  DVI_CONNECTED=`xrandr -q | grep 'DVI-0' | awk '{print $2}'`
  VGA_CONNECTED=`xrandr -q | grep 'VGA-0' | awk '{print $2}'`
fi
echo "PANEL_CONNECTED="${PANEL_CONNECTED}
echo "DVI_CONNECTED="${DVI_CONNECTED}
echo "VGA_CONNECTED="${VGA_CONNECTED}

if [ -z ${1} ]
then
  if [ ${DVI_CONNECTED} = "connected" ]
  then
    echo ${default}
    #CMD="xrandr --auto"
    #echo ${CMD}
    #`${CMD}`
    CMD="xrandr --output ${PANEL_ID} --auto"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${DVI_ID} --auto"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${DVI_ID} --left-of ${PANEL_ID} --primary"
    #CMD="xrandr --output ${PANEL_ID} --right-of ${DVI_ID}"
    echo ${CMD}
    `${CMD}`
  elif [ ${VGA_CONNECTED} = "connected" ]
  then
    echo ${default}
    CMD="xrandr --auto"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${VGA_ID} --auto"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${VGA_ID} --auto"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${VGA_ID} --left-of ${PANEL_ID}"
    echo ${CMD}
    `${CMD}`
  #elif [[ (${DVI_CONNECTED} -eq "disconnected") && (${VGA_CONNECTED} -eq "disconnected") ]]
  #then
  else
    echo ${default}
    CMD="xrandr --output ${PANEL_ID} --auto"
    CMD="xrandr --output ${DVI_ID} --off"
    CMD="xrandr --output ${VGA_ID} --off"
    echo ${CMD}
    `${CMD}`
  fi
elif [ ${1} = "1" ]  
then
  echo ${opt1}
  if [ ${DVI_CONNECTED} = "connected"  -o ${DVI_CONNECTED} = "unknown" ]
  then
    CMD="xrandr --output ${DVI_ID} --same-as ${PANEL_ID}"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${PANEL_ID} --auto"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${DVI_ID} --off"
    echo ${CMD}
    `${CMD}`
  elif [ ${VGA_CONNECTED} = "connected" ]
  then
    CMD="xrandr --output ${VGA_ID} --same-as ${PANEL_ID}"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${PANEL_ID} --auto"
    echo ${CMD}
    `${CMD}`
    CMD="xrandr --output ${VGA_ID} --off"
    echo ${CMD}
    `${CMD}`
  fi     
elif [ ${1} = "2" ]  
then
  echo ${opt2}
  CMD="xrandr --output ${DVI_ID} --primary --left-of ${PANEL_ID}"
  echo ${CMD}
  `${CMD}`
elif [ ${1} = "3" ] 
then
  echo "{opt3}"
  CMD="xrandr --auto"
  echo ${CMD}
  `${CMD}`
elif [ ${1} = "4" ] 
then
  echo ${opt4}
  CMD="xrandr --auto"
  echo ${CMD}
  `${CMD}`
  CMD="xrandr --output ${VGA_ID} --above ${PANEL_ID}"
  echo ${CMD}
  `${CMD}`
elif [ ${1} = "5" ] 
then
  echo "{opt5}"
  CMD="xrandr --auto"
  echo ${CMD}
  `${CMD}`
  CMD="xrandr -s 1024x768"
  echo ${CMD}
  `${CMD}`
  CMD="xrandr --output ${PANEL_ID} --same-as ${VGA_ID}"
  echo ${CMD}
  `${CMD}`
fi


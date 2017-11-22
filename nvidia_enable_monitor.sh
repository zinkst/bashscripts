#!/bin/bash
setDisplayVariables()
{
  if grep --quiet "NVIDIA(GPU-0)" /var/log/Xorg.0.log ; then
      VIDEO_DRIVER="proprietary"
      TP_PANEL_ID="LVDS-0"
      VGA_ID="VGA-0"
      RIGHT_SCREEN="DP-5"
      CENTER_SCREEN="DP-1"
      MINI_DP_SCREEN="DP-0"
  else
      VIDEO_DRIVER="nouveau"
      TP_PANEL_ID="LVDS-1"
      VGA_ID="VGA-1"
      RIGHT_SCREEN="DP-3"
      CENTER_SCREEN="DP-2"
      MINI_DP_SCREEN="DP-1"
  fi 
  echo "VIDEO_DRIVER="${VIDEO_DRIVER}
}
  
getConnectedMonitors()
{
  PANEL_CONNECTED=`xrandr -q | grep ${TP_PANEL_ID} | awk '{print $2}'` 
  VGA_CONNECTED=`xrandr -q | grep ${VGA_ID} | awk '{print $2}'`
  RIGHT_SCREEN_CONNECTED=`xrandr -q | grep ${RIGHT_SCREEN} | awk '{print $2}'`
  CENTER_SCREEN_CONNECTED=`xrandr -q | grep ${CENTER_SCREEN} | awk '{print $2}'`
  MINIDP_SCREEN_CONNECTED=`xrandr -q | grep ${MINI_DP_SCREEN} | awk '{print $2}'`
  echo "PANEL_CONNECTED="${PANEL_CONNECTED}
  echo "VGA_CONNECTED="${VGA_CONNECTED}
  echo "RIGHT_SCREEN_CONNECTED="${RIGHT_SCREEN_CONNECTED}
  echo "CENTER_SCREEN_CONNECTED="${CENTER_SCREEN_CONNECTED}
  echo "MINIDP_SCREEN_CONNECTED="${MINIDP_SCREEN_CONNECTED}
}


option1()
{
  echo ${opt1}
   CMD="xrandr --output ${TP_PANEL_ID} --primary --mode 1920x1080 --output ${CENTER_SCREEN} --off --output ${RIGHT_SCREEN} --off --output ${VGA_ID} --off --output ${MINI_DP_SCREEN} --off"
   echo ${CMD}
    ($CMD)
}

option2()
{  
  echo ${opt2}
  CMD="xrandr --output ${CENTER_SCREEN} --primary --auto --output ${TP_PANEL_ID} --off --output ${RIGHT_SCREEN}  --right-of ${CENTER_SCREEN} --auto"
  echo ${CMD}
  `${CMD}`
}

option6()
{  
  echo ${opt2}
  CMD="xrandr --output ${CENTER_SCREEN} --primary --auto --output ${TP_PANEL_ID} --auto --left-of ${CENTER_SCREEN}  --output ${RIGHT_SCREEN}  --right-of ${CENTER_SCREEN} --auto"
  echo ${CMD}
  `${CMD}`
}

option5()
{  
  echo ${opt5}
  CMD="xrandr --output ${TP_PANEL_ID} --mode 1920x1080 --output ${MINI_DP_SCREEN} --mode 2560x1440 --primary --right-of ${TP_PANEL_ID}"
  echo ${CMD}
  `${CMD}`
}

option3()
{  
  echo ${opt3}
  CMD="xrandr --output ${TP_PANEL_ID} --mode 1920x1080 --primary --output ${VGA_ID} --auto --above ${TP_PANEL_ID}"
  echo ${CMD}
  (${CMD})
}

option4()
{  
  echo {opt4}
  if [ ${VIDEO_DRIVER} == "proprietary" ] 
  then 
      echo "nvidia proprietary driver does not support other resolutions as 1920x1080 (native resolution)"
      echo "manually adding modes does not work"
      CMD='xrandr --newmode  "1024x768_60"   63.50  1024 1072 1176 1328  768 771 775 798 -hsync +vsync'
      echo ${CMD}
      (${CMD})
      CMD="xrandr --addmode ${TP_PANEL_ID} 1024x768_60"
      echo ${CMD}
      (${CMD})
      CMD="xrandr --output ${TP_PANEL_ID} --mode 1024x768_60 --output ${VGA_ID} --mode 1024x768 --same-as ${TP_PANEL_ID}"
      echo ${CMD}
      (${CMD})
  else
      CMD="xrandr --output ${TP_PANEL_ID} --mode 1024x768 --output ${VGA_ID} --mode 1024x768 --same-as ${TP_PANEL_ID}"
      echo ${CMD}
      (${CMD})
  fi  
  
}

automaticSettings()
{
    echo ${default}
    if [ ${CENTER_SCREEN_CONNECTED} == "connected" ] 
    then
        option2
    elif [ ${VGA_CONNECTED} == "connected" ] 
    then
        option4        
    elif [ ${MINIDP_SCREEN_CONNECTED} == "connected" ] 
    then
        option5        
    else # [ ${VGA_CONNECTED} == "disconnected" -a ${CENTER_SCREEN_CONNECTED} == "disconnected" -a  ${MINIDP_SCREEN_CONNECTED} == "disconnected" ]
        option1
    fi    
}

# main starts here
echo "script to switch on and off attached monitors"
echo "usage:"
default="determines all connected monitors and enables them"
opt1="enables Thinkpad TFT only"
opt2="enables Bürosetup Thinkpad TFT off"
opt3="enabling Sub-D and Thinkpad TFT dual screen"
opt4="enables SubD and Thinkpad TFT mirror screen 1024x768" 
opt5="enables HomeOffice setup MiniDP right off LVDS-0"
opt6="enables Bürosetup Thinkpad TFT on"
echo "${0}   -> ${default}"
echo "${0} 1 -> ${opt1}"
echo "${0} 2 -> ${opt2}"
echo "${0} 3 -> ${opt3}"
echo "${0} 4 -> ${opt4}"
echo "${0} 5 -> ${opt5}"
echo "${0} 6 -> ${opt6}"

setDisplayVariables
getConnectedMonitors
case ${1} in
    1 )
        option1 ;;
    2 )
        option2 ;;
    3 )
        option3 ;;
    4 )
        option4 ;;
    5 )
        option5 ;;
    6 )
        option6 ;;
    * )
        automaticSettings ;;
    
esac

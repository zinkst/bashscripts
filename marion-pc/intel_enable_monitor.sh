#!/bin/bash
setDisplayVariables()
{
  PANEL_ID="LVDS-1"
  PANEL_RESOLUTION="1600x900"
  #MONITOR_ID="DP-1"
  MONITOR_ID="HDMI-1"
  MONITOR_RESOLUTION="1920x1080"
}
  
getConnectedMonitors()
{
  MONITOR_CONNECTED=`xrandr -q | grep ${MONITOR_ID} | awk '{print $2}'`
  echo "MONITOR_CONNECTED="${MONITOR_CONNECTED}
}


option1()
{
  echo ${opt1}
  CMD="xrandr --output ${MONITOR_ID} --primary --mode ${MONITOR_RESOLUTION} --output ${PANEL_ID} --off "
   echo ${CMD}
   eval ${CMD}
}


option2()
{  
  echo ${opt2}
  CMD="xrandr --output ${MONITOR_ID} --off --output ${PANEL_ID} --mode ${PANEL_RESOLUTION} --primary"
  echo ${CMD}
  eval ${CMD}
}

option3()
{  
  echo ${opt3}
  CMD="xrandr --output ${MONITOR_ID} --mode ${MONITOR_RESOLUTION} --primary --output ${PANEL_ID} --mode ${PANEL_RESOLUTION} --right-of ${MONITOR_ID}"
  echo ${CMD}
  eval ${CMD}
}

option4()
{  
  echo ${opt2}
  CMD="xrandr --output ${MONITOR_ID} --mode ${PANEL_RESOLUTION} --primary --output ${PANEL_ID} --same-as ${MONITOR_ID}"
  echo ${CMD}
  eval ${CMD}
}

automaticSettings()
{
    echo ${default}
    if [[ ${MONITOR_CONNECTED} == "connected" ]]
    then
        option1
    else 
        option3
    fi    
}

# main starts here
echo "script to switch on and off attached monitors"
echo "usage:"
default="determines all connected monitors and enables them"
opt1="enables Monitor only"
opt2="enables LCD only"
opt3="enables Panel secondary Monitor primary" 
opt4="enabling Screen mirror"
echo "${0}   -> ${default}"
echo "${0} 1 -> ${opt1}"
echo "${0} 2 -> ${opt2}"
echo "${0} 3 -> ${opt3}"
echo "${0} 4 -> ${opt4}"

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

#!/bin/bash
setDisplayVariables()
{
  TV_ID="HDMI1"
  MONITOR_ID="DP1"
}
  
getConnectedMonitors()
{
  TV_CONNECTED=`xrandr -q | grep ${TV_ID} | awk '{print $2}'` 
  MONITOR_CONNECTED=`xrandr -q | grep ${MONITOR_ID} | awk '{print $2}'`
  echo "TV_CONNECTED="${TV_CONNECTED}
  echo "MONITOR_CONNECTED="${MONITOR_CONNECTED}
}


option1()
{
  echo ${opt1}
  CMD="xrandr --output ${MONITOR_ID} --primary --mode 3840x2160 --output ${TV_ID} --off "
   echo ${CMD}
   eval ${CMD}
}

option2()
{  
  echo ${opt2}
  CMD="xrandr --output ${TV_ID} --primary --mode 3840x2160 --output ${MONITOR_ID} --off"
  echo ${CMD}
  `${CMD}`
}

option3()
{  
  echo ${opt3}
  CMD="xrandr --output ${MONITOR_ID} --mode 3840x2160 --primary --output ${TV_ID} --same-as ${MONITOR_ID}"
  echo ${CMD}
  eval ${CMD}
}

option4()
{  
  echo ${opt4}
  CMD="xrandr --output ${MONITOR_ID} --mode 3840x2160 --primary --output ${TV_ID} --mode 3840x2160 --right-of ${MONITOR_ID}"
  echo ${CMD}
  eval ${CMD}
}

automaticSettings()
{
    echo ${default}
    if [[ ${TV_CONNECTED} == "connected" && ${MONITOR_CONNECTED} == "connected" ]]
    then
        option3
    elif [ ${TV_CONNECTED} == "connected" ] 
    then
        option2
    elif [ ${MONITOR_CONNECTED} == "connected" ] 
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
opt2="enables TV only"
opt3="enabling Screen mirror"
opt4="enables TV secondary Monitor primary" 
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

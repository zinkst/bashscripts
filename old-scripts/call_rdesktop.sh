#!/bin/bash
echo "${0} <hostname> <userid> <password> "
if [ -z ${2} ]
then
	USERID="Administrator"
  PASSWORD="eui3258r"
else
	USERID=${2}
  if [ -z ${3} ]
  then
    PASSWORD="eui3258r"
  else
    PASSWORD=${3}
  fi		
fi		
SCREENSIZE="1880x1050"
EXECUTABLE="rdesktop"
#EXECUTABLE="xfreerdp"

#HOST="bld05-10a.boeblingen.de.ibm.com"
echo "${EXECUTABLE} -u ${USERID} -p ${PASSWORD} -g ${SCREENSIZE} -k de ${1} --plugin rdpdr --data disk:ZINKS_DESKTOP:${HOME}/Desktop  &"
if [ ${EXECUTABLE} == "xfreerdp" ]
then
    ${EXECUTABLE} -u ${USERID} -p ${PASSWORD} -g ${SCREENSIZE} -k de ${1} --plugin rdpdr --data disk:ZINKS_DESKTOP:${HOME}/Desktop   &
else    
    ${EXECUTABLE} -u ${USERID} -p ${PASSWORD} -g ${SCREENSIZE} -k de ${1} &
fi    
exit

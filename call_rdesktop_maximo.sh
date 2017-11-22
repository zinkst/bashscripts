#!/bin/bash
USERID="maximo"
PASSWORD="eui3258r"
SCREENSIZE="1580x1120"
#HOST="bld05-10a.boeblingen.de.ibm.com"
rdesktop -u ${USERID} -p ${PASSWORD} -g ${SCREENSIZE} -k de ${1} &
exit

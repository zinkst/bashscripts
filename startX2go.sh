#!/bin/bash
if [ -z ${2} ];
then
  RESUME="--resume NEWEST"
fi
PACK="--pack 16m-jpeg-9"
#PACK="--pack 64k-rdp-compressed"
USER_NAME=${USER_NAME:-devuser}
PASSWORD=${PASSWORD:-passw0rd}
SIZE=${SIZE:-1850x950}
echo "${USER_NAME}/${PASSWORD}" 
pyhoca-cli -u ${USER_NAME} --password ${PASSWORD} --add-to-known-hosts --sound none --kbd-layout de --kbd-type pc105/de -g ${SIZE}  -t desktop -c MATE ${PACK} ${RESUME} --server ${1} &

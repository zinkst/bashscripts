#!/bin/bash
. /links/bin/bkp_functions.sh
LOG_ROOT="/local/backup/rsync_logs/"


determineDistribution
if [ ${DISTRIBUTOR} = "Fedora" ]
then
  echo "running Fedora syncing /boot to /boot-fed-local"
  CMD="rsync -av --delete /boot/ /boot-fed-local"
  echo ${CMD}
  ${CMD}
fi
      

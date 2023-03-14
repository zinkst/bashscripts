#!/bin/bash
source /links/bin/bkp_functions.sh

export SSH_HOST="qnap-ts130"

usage() {
  echo "run ${0} without parameters will power on qnap $SSH_HOST"
  echo "run ${0} -s to power off qnap $SSH_HOST"
}

powerOn() {
  curl -s http://hama-4fach-01/cm?cmnd=Power3%20On
  sleep 30 
  echo "wake up qnap-nas"
  ether-wake 24:5E:BE:4C:C7:EE
}

powerOff() {
  echo "shutdown qnap-nas"
  ssh -l admin ${SSH_HOST} 'poweroff'
  sleep 200
  echo "power off qnap-nas"
  curl -s http://hama-4fach-01/cm?cmnd=Power3%20Off
}

# main
if [ "$(id -u)" -ne 0 ]; then echo "Please run as root." >&2; exit 1; fi

if [ "$#" == 0 ]; then
  echo "no option specified - powering on $SSH_HOST"
  powerOn
  exit 0
fi

while getopts "s" OPTNAME
do
  case "${OPTNAME}" in
    s)
      echo "Option ${OPTNAME} is specified"
      echo "powering off $SSH_HOST"
      powerOff
      ;;
    *)
      usage 
      exit -1
  esac
done

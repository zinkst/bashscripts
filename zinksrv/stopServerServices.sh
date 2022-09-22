#!/bin/bash

SERVER_SERVICES=(home-assist php-fpm nginx mariadb mosquitto.service deCONZ grafana-server influxdb)


function serviceStart () {
  START_ORDER=(3 4 5 6 7 2 1 0)
  for idx in "${START_ORDER[@]}"; 
  do 
    echo "############ starting of ${SERVER_SERVICES[$idx]} ###############################";
    cmd="systemctl start ${SERVER_SERVICES[$idx]}"
    echo $cmd
    eval $cmd
    echo ""
  done  
}

function serviceOperation () {
  OPERATION=${1}
  for srv in "${SERVER_SERVICES[@]}"; 
  do 
    echo "############ ${OPERATION} of $srv ###############################";
    cmd="systemctl ${OPERATION} ${srv} ${2}"
    echo $cmd
    eval $cmd
    echo ""
  done
}


# main

if [ -z "$1" ]; then
    echo "No argument supplied "
    echo "To stop services run"
    echo "${0} -k "
    echo "To start services run"
    echo "${0} -s "
    echo "To enbale services run"
    echo "${0} -e "
    echo "To disable services run"
    echo "${0} -d "
    exit -1
fi

while getopts "sked" Option
do
  case $Option in
    s ) serviceStart;;
    k ) serviceOperation stop;;
    d ) serviceOperation disable;;
    e ) serviceOperation enable;;
  esac
done

serviceOperation status --no-pager 
podman ps

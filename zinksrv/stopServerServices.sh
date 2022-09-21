#!/bin/bash

SERVER_SERVICES=(php-fpm nginx mariadb mosquitto.service home-assistant deCONZ grafana-server influxdb)

function serviceStatus () {
  for srv in "${SERVER_SERVICES[@]}"; 
  do 
    echo "############ status of $srv ###############################";
    cmd="systemctl status ${srv} --no-pager"
    echo $cmd
    eval $cmd
    echo ""
  done
  podman ps
}

function serviceStop () {
  for srv in "${SERVER_SERVICES[@]}"; 
  do 
    echo "############ status of $srv ###############################";
    cmd="systemctl stop ${srv}"
    echo $cmd
    eval $cmd
    echo ""
  done
}

function serviceStart () {
  START_ORDER=(2 5 6 7 3 4 1 0)
  for idx in "${START_ORDER[@]}"; 
  do 
    echo "############ starting of ${SERVER_SERVICES[$idx]} ###############################";
    cmd="systemctl start ${SERVER_SERVICES[$idx]}"
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
    exit -1
fi

while getopts "sk" Option
do
  case $Option in
    k ) serviceStop;;
    s ) serviceStart;;
  esac
done


serviceStatus

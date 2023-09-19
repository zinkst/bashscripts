#!/bin/bash

function stopAll() {
    for svc in "${stopServicesSequence[@]}"
    do
        echo "==================================== stopping $svc ======================================================="
        cmd="systemctl --no-pager stop $svc"
        echo $cmd
        eval $cmd
    done
}

function disableAll() {
    for svc in "${stopServicesSequence[@]}"
    do
        echo "==================================== disabling $svc ======================================================="
        cmd="systemctl --no-pager disable $svc"
        echo $cmd
        eval $cmd
    done
}

function enableAll() {
    for svc in "${stopServicesSequence[@]}"
    do
        echo "==================================== enabling $svc ======================================================="
        cmd="systemctl --no-pager enable $svc"
        echo $cmd
        eval $cmd
    done
}

function statusAll() {
    for svc in "${stopServicesSequence[@]}"
    do
        echo "==================================== stopping $svc ======================================================="
        cmd="systemctl --no-pager status $svc"
        echo $cmd
        eval $cmd
    done
}

function startAll() {
    startServices=(mariadb influxdb smb.service nfs-server.service grafana-server.service nginx php-fpm deCONZ.service home-assist.service node-red.service)
    for svc in "${startServices[@]}"
    do
        echo "==================================== starting $svc ======================================================="
        cmd="systemctl start $svc"
        echo $cmd
        eval $cmd
    done
}
#main
stopServicesSequence=(php-fpm nginx grafana-server.service deCONZ.service home-assist.service node-red.service influxdb mariadb smb.service nfs-server.service )
# stopAll
# disableAll
enableAll
statusAll
# startAll
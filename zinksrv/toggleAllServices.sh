#!/bin/bash


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

function toggleAll() {
    OPERATION=${1}
    stopServicesSequence=(php-fpm nginx grafana-server.service deCONZ.service home-assist.service node-red.service influxdb mariadb smb.service nfs-server.service )
    for svc in "${stopServicesSequence[@]}"
    do
        echo "==================================== toggling operation ${OPERATION} for service $svc ======================================================="
        cmd="systemctl --no-pager ${OPERATION} $svc"
        echo $cmd
        eval $cmd
    done
}

function usage {
    echo "no argument specified usage:"
    echo "${0} [ -s | -o operation ]"
    echo "operation : [stop | enable | disable | status ]" 
}

#main

# main
if [[ $1 == "" ]]; then
   usage;
   exit 1;
else
    while getopts "o:s" OPTNAME
    do
        case "${OPTNAME}" in
            "s")
            echo "Operation selected ist start"
            startAll
            ;;
            "o")
            echo "Option o with value  ${OPTARG} is specified"
            toggleAll ${OPTARG}
            ;;
            "*")
            usage
            exit 1
            ;;
        
        esac
    done
fi

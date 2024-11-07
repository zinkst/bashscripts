#!/bin/bash


function toggleAll() {
    OPERATION=${1}
    stopServicesSequence=(nexcloud-pod grafana-server.service zigbee2mqtt.service home-assistant.service node-red.service influx-db.service smb.service nfs-server.service )
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
    echo "${0} [ -o operation ]"
    echo "operation : [start | stop | enable | disable | status ]" 
}

#main

# main
if [[ $1 == "" ]]; then
   usage;
   exit 1;
else
    while getopts "o:" OPTNAME
    do
        case "${OPTNAME}" in
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

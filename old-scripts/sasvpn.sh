#!/bin/bash
if [ "$1" == "stop" ]; then
    sudo killall -s SIGINT openconnect
else
    sudo openconnect --config=/links/workdata/ibm/Infrastructure/SAS-VPN/ibm_sas_vpn.cfg https://sasvpn.emea.ibm.com
fi

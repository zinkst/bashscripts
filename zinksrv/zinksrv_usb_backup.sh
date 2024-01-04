#!/bin/bash
export USB1_TGT_DEVICE="/dev/disk/by-id/wwn-0x50014ee0aeb36c58-part1"
export USB2_TGT_DEVICE="/dev/disk/by-id/wwn-0x50014ee204b797e8-part1"

source /links/bin/resticFunctions.sh

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

powerOnTasmotaPlug "hama-4fach-01" "Power2"
if [ -L ${USB2_TGT_DEVICE} ]; then
    echo "found USB2 Device ${USB2_TGT_DEVICE}"
    /links/bin/zinksrv/zinksrv_restic_usb-2.sh
elif [ -L ${USB1_TGT_DEVICE} ]; then
    echo "found USB1 Device ${USB1_TGT_DEVICE}"
    /links/bin/zinksrv/zinksrv_restic_usb.sh
else
    echo "No USB Device found - Powering Off USB Backup"
    curl -s http://hama-4fach-01/cm?cmnd=Power2%20Off && echo
    echo "finished"
fi        
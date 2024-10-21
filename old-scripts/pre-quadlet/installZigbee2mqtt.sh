#!/bin/bash
SERVICE_NAME="zigbee2mqtt"
CONTAINER_IMAGE="koenkk/zigbee2mqtt"
DATA_DIR="/local/data/$(hostname -s)/srv/${SERVICE_NAME}"

source /links/bin/lib/podmanFunctions.sh

function createConfig() {
  mkdir -p ${DATA_DIR}  
  wget https://raw.githubusercontent.com/Koenkk/zigbee2mqtt/master/data/configuration.yaml -P ${DATA_DIR}
}


function createPod() {
   podman run \
   --name=${SERVICE_NAME} \
   --net=host \
   -v /etc/localtime:/etc/localtime:ro \
   -v ${DATA_DIR}:/app/data \
   -v /run/udev:/run/udev:ro \
   --device=/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20231122164512-if00:/dev/ttyACM0 \
   -e TZ=Europe/Amsterdam \
   ${CONTAINER_IMAGE}
}


function install() {
    pullImage
    createConfig
    createPod
    createSystemdService
}

# main
main $@
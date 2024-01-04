#!/bin/bash
SERVICE_NAME="zigbee2mqtt"
CONTAINER_IMAGE="koenkk/zigbee2mqtt"
DATA_DIR="/local/data/$(hostname -s)/srv/${SERVICE_NAME}"

function createConfig() {
  mkdir -p ${DATA_DIR}  
  wget https://raw.githubusercontent.com/Koenkk/zigbee2mqtt/master/data/configuration.yaml -P ${DATA_DIR}
}

function createSystemdService() {
cat << EOF > /etc/systemd/system/${SERVICE_NAME}.service
[Unit]
Description=${SERVICE_NAME} podman container

[Service]
Restart=always
ExecStart=/usr/bin/podman start -a ${SERVICE_NAME}
ExecStop=/usr/bin/podman stop ${SERVICE_NAME}

[Install]
WantedBy=multi-user.target
EOF

  systemctl enable ${SERVICE_NAME}.service
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

function pullImage() {
  podman pull ${CONTAINER_IMAGE}:stable
}  

function update() {
  pull-image
  systemctl stop ${SERVICE_NAME}.service
  podman stop ${SERVICE_NAME} 
  podman rm ${SERVICE_NAME}
  create-pod
  systemctl start ${SERVICE_NAME}.service
}

function install() {
    pullImage
    createConfig
    createPod
    createSystemdService
}

function usage {
    echo "no argument specified usage:"
    echo "${0} -u # update"
    echo "${0} -i # install"
}

# main
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

if [[ $1 == "" ]]; then
   usage;
   exit 1;
else
    while getopts "ui" OPTNAME
    do
        case "${OPTNAME}" in
            "u")
            echo "Operation selected ist update"
            update
            ;;
            "i")
            echo "Operation selected ist install"
            install
            ;;
            "*")
            usage
            exit 1
            ;;
        esac
    done
fi


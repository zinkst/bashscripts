#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function createDirs() {
  mkdir -p ${QUADLET_DIR}
  mkdir -p ${DATA_DIR}
  semanage fcontext -a -t svirt_sandbox_file_t "${DATA_DIR}(/.*)?"
  restorecon -Rv "${DATA_DIR}"
}

function CreateQuadlet() {
  cat <<EOF > ${QUADLET_DIR}/${SERVICE_NAME}.container 
[Unit]
Description=${SERVICE_NAME}

[Container]
Label=app=${SERVICE_NAME}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=${SERVICE_NAME}
Image=${ZIGBEE2MQTT_CONTAINER_IMAGE}
Network=${NETWORK_NAME}
PublishPort=${ZIGBEE2MQTT_HTTP_PORT}:8080
Volume=${DATA_DIR}:/app/data:Z
Volume=/run/udev:/run/udev:ro
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam
AddDevice=/dev/serial/by-id/${ZIGBEE2MQTT_USB_DEVICE}:/dev/ttyACM0
Exec=docker-entrypoint.sh /sbin/tini -- node index.js
SecurityLabelDisable=true
# AddHost=host.containers.internal:host-gateway # resolves to correct Address but still ECONREFUSED

[Install]
${START_ON_BOOT}
EOF
}


function setEnvVars() {
  setDefaultEnvVars
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  DATA_DIR="$(yq -r '.ZIGBEE2MQTT.DATA_DIR' "${CONFIG_YAML}")"
  ZIGBEE2MQTT_CONTAINER_IMAGE="$(yq -r '.ZIGBEE2MQTT.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  ZIGBEE2MQTT_HTTP_PORT="$(yq -r '.ZIGBEE2MQTT.HTTP_PORT' "${CONFIG_YAML}")"
  ZIGBEE2MQTT_USB_DEVICE="$(yq -r '.ZIGBEE2MQTT.USB_DEVICE' "${CONFIG_YAML}")"
  START_ON_BOOT="$(yq -r '.ZIGBEE2MQTT.START_ON_BOOT' "${CONFIG_YAML}")" 
  SERVICE_NAME="zigbee2mqtt"
}

function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo DATA_DIR=${DATA_DIR}
  echo ZIGBEE2MQTT_CONTAINER_IMAGE=${ZIGBEE2MQTT_CONTAINER_IMAGE}
  echo ZIGBEE2MQTT_HTTP_PORT=${ZIGBEE2MQTT_HTTP_PORT}
  echo ZIGBEE2MQTT_USB_DEVICE=${ZIGBEE2MQTT_USB_DEVICE}
  echo SERVICE_NAME=${SERVICE_NAME}
  echo START_ON_BOOT=${START_ON_BOOT}
}

function install() {
  createDirs
  CreateQuadlet
  postInstall
  showStatus
}

main "$@"
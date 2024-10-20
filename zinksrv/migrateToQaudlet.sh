#!/bin/bash

function migratehomeAssistant() {
  systemctl stop home-assist.service
  mkdir -p /local/data/$(hostname -s)/srv/home-assistant
  cp -prv /local/data/$(hostname -s)/srv/home-assist/home-assistant-config /local/data/$(hostname -s)/srv/home-assistant
  systemctl disable home-assist.service
  /links/bin/quadlet/homeAssistantQuadlets.sh -c "/links/etc/my-etc/quadlet/config-$(hostname -s).yml" -i 
}

function migrateZigbee2mqtt() {
    systemctl disable zigbee2mqtt.service --now
    export SERVICE_NAME="zigbee2mqtt"
    export BACKUP_DIR=/links/sysbkp/${SERVICE_NAME}
    tar -czf  ${BACKUP_DIR}/$(date +'%y%m%d_%H%M%S')_${SERVICE_NAME}.tgz --directory ${ZIGBEE2MQTT_DATA_DIR}/ .
    /links/bin/quadlet/zigbee2mqttQuadlet.sh -c "/links/etc/my-etc/quadlet/config-$(hostname -s).yml" -i 
}

# main
migratehomeAssistant
migrateZigbee2mqtt
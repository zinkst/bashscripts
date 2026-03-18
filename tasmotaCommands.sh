#!/bin/bash

# powerOnTasmotaPlug "hama-4fach-01" "Power2"
function powerOnTasmotaPlug() {
    POWER_STATE=$(curl -s http://${1}/cm?cmnd=${2} | jq '.POWER2')
    if [ "${POWER_STATE}" != '"ON"' ]; then
        echo "Power On ${1} ${2}"
        curl -s http://${1}/cm?cmnd=${2}%20On && echo
        echo "waiting 30 seconds" && sleep 30
    else
        echo "${1} ${2} already powered on"
    fi
}  



function setWifiConfig() {
  TASMOTA_DEVICE_IP_ADDR="${1}"
  echo "setting wifi for ${TASMOTA_DEVICE_IP_ADDR}"
  SSID2=$(curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=SSID2 | jq -r '.SSId2') 
  if [ "${SSID2}" != "ZINKS_WLAN" ]; then
    TASMOTA_CMD=SSID2
    curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=${TASMOTA_CMD}%20ZINKS_WLAN
    TASMOTA_CMD=Password2
    curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=${TASMOTA_CMD}%20burghalde
    confirmOutput
    sleep 10
  else  
    echo "${TASMOTA_DEVICE_IP_ADDR} SSID2=${SSID2} already correct"
  fi

  SSID1=$(curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=SSID1 | jq -r '.SSId1' )
  if [ "${SSID1}" != "ZINKS_WLAN_2.4" ]; then
    TASMOTA_CMD=SSID1
    curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=${TASMOTA_CMD}%20ZINKS_WLAN_2.4
    TASMOTA_CMD=Password1
    curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=${TASMOTA_CMD}%20zinks2.4
    confirmOutput
  else
    echo "${TASMOTA_DEVICE_IP_ADDR} SSID1=${SSID1} already correct"
  fi  
}

function confirmOutput() {
  echo
  read -p "Output correct and Continue (j/n)?" CONT
	if [ "$CONT" == "n" ]; then
		echo "exiting";
    exit 0
	fi
}

function getConfig() {
  TASMOTA_DEVICE_IP_ADDR="${1}"
  SSID1=$(curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=SSID1 | jq -r '.SSId1' )
  SSID2=$(curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=SSID2 | jq -r '.SSId2') 
  FW_VERSION=$(curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=Status%202 | jq -r '.StatusFWR.Version')
  AP=$(curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=Ap)
  echo Device Summary for ${TASMOTA_DEVICE_IP_ADDR} 
  echo FW_VERSION=${FW_VERSION} SSID1=${SSID1} SSID2=${SSID2}
}

function updateTasmota() {
  TASMOTA_DEVICE_IP_ADDR="${1}"
  OTA_URL=$(curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=OtaUrl)
  echo OTA_URL=${OTA_URL}
  # curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=Status%200
  curl -s http://${TASMOTA_DEVICE_IP_ADDR}/cm?cmnd=Upgrade%201
  echo
}



# main
ALL_TASMOTA_DEVICES=(
  gosund-usb-01
  gosund-usb-02
  gosund-usb-03
  gosund-usb-04
  gosund-usb-05
  gosund-usb-06
  gosund-01
  gosund-02
  nous-01
  nous-02
  nous-03
  nous-04
  nous-05
  nous-06
  hama-4fach-01
  nous-a5t-01
  nous-a5t-02
  nous-a5t-03
)

TASMOTA_DEVICES=(
  nous-02
  nous-03
  nous-05
  nous-06
  nous-a5t-01
  nous-a5t-02
  nous-a5t-03
)

for device in "${ALL_TASMOTA_DEVICES[@]}"
do
   getConfig "$device"
   # setWifiConfig "$device"
   # updateTasmota "$device"
done
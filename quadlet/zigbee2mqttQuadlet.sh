#!/bin/bash
set -euo pipefail

function createDirs() {
  mkdir -p ${QUADLET_DIR}
  mkdir -p ${ZIGBEE2MQTT_DATA_DIR}
  semanage fcontext -a -t svirt_sandbox_file_t "${ZIGBEE2MQTT_DATA_DIR}(/.*)?"
  restorecon -Rv "${ZIGBEE2MQTT_DATA_DIR}"
}

function createPrereqs() {
  echo "Createing Prereqs for ${SERVICE_NAME}"
  # printf "${VAULTWARDEN_ADMIN_TOKEN}" | podman secret create --replace vaultwarden-admin-token -
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
Volume=${ZIGBEE2MQTT_DATA_DIR}:/app/data:Z
Volume=/run/udev:/run/udev:ro
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam
AddDevice=/dev/serial/by-id/${ZIGBEE2MQTT_USB_DEVICE}:/dev/ttyACM0
Exec=docker-entrypoint.sh /sbin/tini -- node index.js
SecurityLabelDisable=true
# AddHost=host.containers.internal:host-gateway # resolves to correct Address but still ECONREFUSED

[Install]
WantedBy=default.target
EOF
}


function CreateUnitNextcloudNetwork() {
  podman network create ${NETWORK_NAME} --ignore
}

function postInstall() {
  ${SYSTEMCTL_CMD} daemon-reload
  ${SYSTEMCTL_CMD} start ${SERVICE_NAME}.service
  if [[ $(id -u) -ne 0 ]] ; then 
    loginctl enable-linger $USER
  fi 
}


function uninstall() {
  ${SYSTEMCTL_CMD} disable --now ${SERVICE_NAME}.service
  if [[ $(id -u) -ne 0 ]] ; then 
    loginctl disable-linger $USER
  fi 
  rm "${QUADLET_DIR}/${SERVICE_NAME}.container"
  
}

function showStatus() {
  SERVICES=(
    ${SERVICE_NAME}
  )
  for  i in ${!SERVICES[@]}; do
        echo "###################################################"
        echo "Show status for service ${SERVICES[$i]}"
        ${SYSTEMCTL_CMD} --no-pager is-active  ${SERVICES[$i]}
  done
}

function setEnvVars() {
  if [[ $(id -u) -eq 0 ]] ; then 
    echo "running as USER root" 
    export QUADLET_DIR=/etc/containers/systemd
    export SYSTEMD_UNIT_DIR=/etc/systemd/system
    export SYSTEMCTL_CMD="systemctl"
  else  
    echo "running as USER ${USER}" 
    export QUADLET_DIR=${HOME}/.config/containers/systemd
    export SYSTEMD_UNIT_DIR=${HOME}/.config/systemd/user
    export SYSTEMCTL_CMD="systemctl --user"
  fi
  NETWORK_NAME="$(yq -r '.HOST.PODMAN_NETWORK_NAME' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  ZIGBEE2MQTT_DATA_DIR="$(yq -r '.ZIGBEE2MQTT.DATA_DIR' "${CONFIG_YAML}")"
  ZIGBEE2MQTT_CONTAINER_IMAGE="$(yq -r '.ZIGBEE2MQTT.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  ZIGBEE2MQTT_HTTP_PORT="$(yq -r '.ZIGBEE2MQTT.HTTP_PORT' "${CONFIG_YAML}")"
  ZIGBEE2MQTT_USB_DEVICE="$(yq -r '.ZIGBEE2MQTT.USB_DEVICE' "${CONFIG_YAML}")"
  SERVICE_NAME="zigbee2mqtt"
}

function printEnvVars() {
  echo CONFIG_YAML="${CONFIG_YAML}"
  echo QUADLET_DIR=${QUADLET_DIR}
  echo SYSTEMD_UNIT_DIR=${SYSTEMD_UNIT_DIR}
  echo SYSTEMCTL_CMD=${SYSTEMCTL_CMD}
  echo NETWORK_NAME=${NETWORK_NAME}
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo ZIGBEE2MQTT_DATA_DIR=${ZIGBEE2MQTT_DATA_DIR}
  echo ZIGBEE2MQTT_CONTAINER_IMAGE=${ZIGBEE2MQTT_CONTAINER_IMAGE}
  echo ZIGBEE2MQTT_HTTP_PORT=${ZIGBEE2MQTT_HTTP_PORT}
  echo ZIGBEE2MQTT_USB_DEVICE=${ZIGBEE2MQTT_USB_DEVICE}
  echo SERVICE_NAME=${SERVICE_NAME}
}

function install() {
  createDirs
  createPrereqs
  CreateQuadlet
  postInstall
  showStatus
}


function usage() {
  echo "##################"
  echo "Parameters available"
  echo "-c <path-to-config-file> (required) "
  echo "-i to install"
  echo "-u to uninstall"
  echo "-s to show status of services"
}

function checkpCLIParams() {
  while getopts "iusc:" OPTNAME; do
    case "${OPTNAME}" in
      i )
        echo "Runmode Option ${OPTNAME} is specified"
        RUN_MODE="INSTALL"
        ;;
      u )
        echo "Runmode Option ${OPTNAME} is specified"
        RUN_MODE="UNINSTALL"
        ;;
      s )
        echo "Runmode Option ${OPTNAME} is specified"
        RUN_MODE="STATUS"
        ;;
      c )
        echo "config file used is \"${OPTARG}\" is specified"
        CONFIG_YAML="${OPTARG}"
        ;;
      * )
        echo "unknown parameter specified"
        usage
        exit 1
        ;;
    esac
  done
  if [ $OPTIND -eq 1 ]; then 
    echo "No options were passed"; 
    usage
    exit 1
  fi

  if [ -z "${CONFIG_YAML+x}" ]  || [ ! -f "${CONFIG_YAML}" ]; then 
    echo "Config file does not exist Please specify an existing config file witch -c"; 
    usage
  fi
  if [ -z "${RUN_MODE+x}" ]; then
     echo "No Runmode mode specified specify either -c or -u"
     usage
     exit 1
  fi   
}

# main start here
checkpCLIParams "$@"
setEnvVars
printEnvVars
case "${RUN_MODE}" in 
   "INSTALL" )
     echo "installing ${SERVICE_NAME}"
     install ;;
   "UNINSTALL")
     echo "uninstalling ${SERVICE_NAME}"
     uninstall ;;
   "STATUS")
     showStatus ;;
   * )
     echo "Invalid Installation mode specified specifed us either -c or -u parameter"
     usage; 
     exit 1
     ;;
 esac    



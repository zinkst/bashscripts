#!/bin/bash
set -euo pipefail

function CreateQuadlet() {
  mkdir -p ${PROMETHEUS_DATA_DIR}
  cat <<EOF > ${QUADLET_DIR}/${SERVICE_NAME}.container 
[Unit]
Description=${SERVICE_NAME}
Wants=network-online.target
After=network-online.target

[Container]
Label=app=${SERVICE_NAME}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=${SERVICE_NAME}
Image=${CONTAINER_IMAGE}
Network=${NETWORK_NAME}
PublishPort=${PROMETHEUS_HTTP_PORT}:9090
Volume=${PROMETHEUS_DATA_DIR}:/prometheus,z
Volume=${PROMETHEUS_ETC_DIR}:/etc/prometheus,z
AddCapability=CAP_AUDIT_WRITE

[Install]
WantedBy=default.target
EOF
}

function CreatePrometheusConfig() {
  mkdir -p ${PROMETHEUS_ETC_DIR}/prometheus
  cat <<EOF > ${PROMETHEUS_ETC_DIR}/prometheus/prometheus.yml
EOF
}

function CreatePodmanNetwork() {
  podman network create ${NETWORK_NAME} --ignore
}


function postInstall() {
  ${SYSTEMCTL_CMD} daemon-reload
  ${SYSTEMCTL_CMD} start ${SERVICE_NAME}.service
}

function uninstall() {
  ${SYSTEMCTL_CMD} stop ${SERVICE_NAME}.service
  rm ${QUADLET_DIR}/${SERVICE_NAME}.container
}

function setEnvVars() {
  SERVICE_NAME="prometheus"
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
  PROMETHEUS_DATA_DIR="$(yq -r '.PROMETHEUS.DATA_DIR' "${CONFIG_YAML}")"
  PROMETHEUS_ETC_DIR="$(yq -r '.PROMETHEUS.ETC_DIR' "${CONFIG_YAML}")"
  SERVER_IP=$(hostname -I | awk '{print $1}')
  PROMETHEUS_HTTP_PORT="$(yq -r '.PROMETHEUS.HTTP_PORT' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  CONTAINER_IMAGE="$(yq -r '.PROMETHEUS.CONTAINER_IMAGE' "${CONFIG_YAML}")" 
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

function printEnvVars() {
  echo CONFIG_YAML=${CONFIG_YAML}
  echo QUADLET_DIR=${QUADLET_DIR}
  echo SYSTEMD_UNIT_DIR=${SYSTEMD_UNIT_DIR}
  echo SYSTEMCTL_CMD=${SYSTEMCTL_CMD}
  echo NETWORK_NAME=${NETWORK_NAME}
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo SERVER_IP=${SERVER_IP}
  echo PROMETHEUS_DATA_DIR=${PROMETHEUS_DATA_DIR}
  echo PROMETHEUS_ETC_DIR=${PROMETHEUS_ETC_DIR}
  echo PROMETHEUS_HTTP_PORT=${PROMETHEUS_HTTP_PORT}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
}

function install() {
  CreatePodmanNetwork
  CreateQuadlet
  CreatePrometheusConfig
  postInstall
  showStatus
}


function usage() {
  echo "##################"
  echo "Parameters available"
  echo "-c <path-to-config-file> (required) "
  echo "-i to install ${SERVICE_NAME}"
  echo "-u to uninstall ${SERVICE_NAME}"
  echo "-s to show status of ${SERVICE_NAME} "
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
     echo "installing"
     install ;;
   "UNINSTALL")
     echo "uninstalling"
     uninstall ;;
   "STATUS")
     echo "showing status"
     showStatus ;;
   * )
     echo "Invalid Installation mode specified specifed us either -c or -u parameter"
     usage; 
     exit 1
     ;;
 esac    



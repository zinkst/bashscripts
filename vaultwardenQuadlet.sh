#!/bin/bash
set -euo pipefail

function createDirs() {
  mkdir -p ${QUADLET_DIR}
  mkdir -p ${VAULTWARDEN_DATA_DIR}
  semanage fcontext -a -t svirt_sandbox_file_t "${VAULTWARDEN_DATA_DIR}(/.*)?"
  restorecon -Rv "${VAULTWARDEN_DATA_DIR}"
}

function createPrereqs() {
  printf "${VAULTWARDEN_ADMIN_TOKEN}" | podman secret create --replace vaultwarden-admin-token -
}

function CreateQuadletVaultwarden() {
  cat <<EOF > ${QUADLET_DIR}/${SERVICE_NAME}.container 
[Unit]
Description=${SERVICE_NAME}

[Container]
Label=app=${SERVICE_NAME}
AutoUpdate=registry
ContainerName=${SERVICE_NAME}
Image=${VAULTWARDEN_CONTAINER_IMAGE}
Network=${NETWORK_NAME}
PublishPort=${VAULTWARDEN_ROCKET_PORT}:${VAULTWARDEN_ROCKET_PORT}
Volume=${VAULTWARDEN_DATA_DIR}:/data:Z
Volume=/etc/localtime:/etc/localtime:ro
Environment=DOMAIN=https://${CADDY_PROXY_DOMAIN}/vaultwarden
Environment=TZ=Europe/Amsterdam
Environment=ROCKET_PORT=${VAULTWARDEN_ROCKET_PORT}
Secret=vaultwarden-admin-token,type=env,target=ADMIN_TOKEN

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
  podman secret rm vaultwarden-admin-token
  
}

function showStatus() {
  SERVICES=(
    vaultwarden
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
  NETWORK_NAME="$(yq -r '.HOST.PODMAN_NETWORK_NAME' ${CONFIG_YAML})"
  VAULTWARDEN_DATA_DIR="$(yq -r '.VAULTWARDEN.DATA_DIR' ${CONFIG_YAML})"
  VAULTWARDEN_ADMIN_TOKEN="$(yq -r '.VAULTWARDEN.ADMIN_TOKEN' ${CONFIG_YAML})"
  VAULTWARDEN_CONTAINER_IMAGE="$(yq -r '.VAULTWARDEN.CONTAINER_IMAGE' ${CONFIG_YAML})"
  VAULTWARDEN_ROCKET_PORT="$(yq -r '.VAULTWARDEN.ROCKET_PORT' ${CONFIG_YAML})"
  CADDY_PROXY_DOMAIN="$(yq -r '.CADDY.PROXY_DOMAIN' ${CONFIG_YAML})"
  SERVICE_NAME=vaultwarden
}

function printEnvVars() {
  echo CONFIG_YAML=${CONFIG_YAML}
  echo QUADLET_DIR=${QUADLET_DIR}
  echo SYSTEMD_UNIT_DIR=${SYSTEMD_UNIT_DIR}
  echo SYSTEMCTL_CMD=${SYSTEMCTL_CMD}
  echo VAULTWARDEN_DATA_DIR=${VAULTWARDEN_DATA_DIR}
  echo VAULTWARDEN_ADMIN_TOKEN=${VAULTWARDEN_ADMIN_TOKEN}
  echo VAULTWARDEN_CONTAINER_IMAGE=${VAULTWARDEN_CONTAINER_IMAGE}
  echo VAULTWARDEN_ROCKET_PORT=${VAULTWARDEN_ROCKET_PORT}
  echo SERVICE_NAME=${SERVICE_NAME}
  echo CADDY_PROXY_DOMAIN=${CADDY_PROXY_DOMAIN}
}

function install() {
  createDirs
  createPrereqs
  CreateQuadletVaultwarden
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
        echo "config file used is ${OPTARG} is specified"
        CONFIG_YAML=${OPTARG}
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

  if [ -z "${CONFIG_YAML+x}" ]  || [ ! -f ${CONFIG_YAML} ]; then 
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
checkpCLIParams $*
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



#!/bin/bash
set -euo pipefail

function CreateQuadletCaddy() {
  mkdir -p ${CADDY_ROOT_DIR}/data
  cat <<EOF > ${CADDYFILE}
# Caddy file
# to enable tls again replace :8000 with :80 and restart Caddy
# make sure nginx is stopped while port 80 is active 
:80 {
	respond "Hello, world!"
    # templates
    # file_server browse
}

:${NEXTCLOUD_HTTP_PORT} {
  root * /var/www/html
  file_server
  php_fastcgi nextcloud-app:9000
  redir /.well-known/carddav /remote.php/dav/ 301
  redir /.well-known/caldav /remote.php/dav/ 301
  # .htaccess / data / config / ... shouldn't be accessible from outside
  @forbidden {
          path    /.htaccess
          path    /data/*
          path    /config/*
          path    /db_structure
          path    /.xml
          path    /README
          path    /3rdparty/*
          path    /lib/*
          path    /templates/*
          path    /occ
          path    /console.php
  }
  respond @forbidden 404
}

${CADDY_PROXY_DOMAIN}:${NEXTCLOUD_HTTPS_PORT} {
  redir /.well-known/carddav /remote.php/dav/ 301
  redir /.well-known/caldav /remote.php/dav/ 301

  header {
      Strict-Transport-Security max-age=31536000;
  }
  
  # for local testing uncomment the following line
  # tls internal

  # Change below to host IP
  reverse_proxy ${SERVER_IP}:${NEXTCLOUD_HTTP_PORT}
}

${CADDY_PROXY_DOMAIN}:${VAULTWARDEN_HTTPS_PORT} {
	reverse_proxy ${SERVER_IP}:${VAULTWARDEN_ROCKET_PORT}
  # for local testing uncomment the following line
  # tls internal
}
EOF

  cat <<EOF > ${QUADLET_DIR}/caddy.container 
[Unit]
Description=caddy
Wants=network-online.target
After=network-online.target

[Container]
# Pod=nextcloud.pod
Label=app=nextcloud
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=caddy
Image=docker.io/caddy:latest
Network=${NETWORK_NAME}
PublishPort=${NEXTCLOUD_HTTP_PORT}:${NEXTCLOUD_HTTP_PORT}
PublishPort=${NEXTCLOUD_HTTPS_PORT}:${NEXTCLOUD_HTTPS_PORT}
PublishPort=${VAULTWARDEN_HTTPS_PORT}:${VAULTWARDEN_HTTPS_PORT}
Volume=${CADDYFILE}:/etc/caddy/Caddyfile:z
Volume=${CADDY_ROOT_DIR}/data:/data:Z
Volume=${NEXTCLOUD_ROOT_DIR}/html:/var/www/html:ro,z
AddCapability=CAP_AUDIT_WRITE

[Install]
WantedBy=default.target
EOF
}

function CreatePodmanNetwork() {
  podman network create ${NETWORK_NAME} --ignore
}


function postInstall() {
  ${SYSTEMCTL_CMD} daemon-reload
  ${SYSTEMCTL_CMD} start caddy.service
  if [[ $(id -u) -eq 0 ]] ; then 
    cp ${CADDY_ROOT_DIR}/data/caddy/pki/authorities/local/root.crt /etc/pki/ca-trust/source/anchors/caddy-root-ca.crt
    update-ca-trust
  fi  
}

function uninstallCaddy() {
  ${SYSTEMCTL_CMD} stop caddy.service
  rm ${QUADLET_DIR}/caddy.container
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
  CADDYFILE="$(yq -r '.CADDY.CADDYFILE' ${CONFIG_YAML})"
  CADDY_PROXY_DOMAIN="$(yq -r '.CADDY.PROXY_DOMAIN' ${CONFIG_YAML})"
  CADDY_ROOT_DIR="$(yq -r '.CADDY.ROOT_DIR' ${CONFIG_YAML})"
  NEXTCLOUD_ROOT_DIR="$(yq -r '.NEXTCLOUD.ROOT_DIR' ${CONFIG_YAML})"
  SERVER_IP=$(hostname -I | awk '{print $1}')
  NEXTCLOUD_HTTP_PORT="$(yq -r '.NEXTCLOUD.HTTP_PORT' ${CONFIG_YAML})"
  NEXTCLOUD_HTTPS_PORT="$(yq -r '.NEXTCLOUD.HTTPS_PORT' ${CONFIG_YAML})"
  VAULTWARDEN_HTTPS_PORT="$(yq -r '.VAULTWARDEN.HTTPS_PORT' ${CONFIG_YAML})"
  VAULTWARDEN_ROCKET_PORT="$(yq -r '.VAULTWARDEN.ROCKET_PORT' ${CONFIG_YAML})"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' ${CONFIG_YAML})"
}


function showStatus() {
  SERVICES=(
    caddy
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
  echo CADDY_PROXY_DOMAIN=${CADDY_PROXY_DOMAIN}
  echo CADDYFILE=${CADDYFILE}
  echo CADDY_ROOT_DIR=${CADDY_ROOT_DIR}
  echo NEXTCLOUD_ROOT_DIR=${NEXTCLOUD_ROOT_DIR}
  echo NEXTCLOUD_HTTP_PORT=${NEXTCLOUD_HTTP_PORT}
  echo NEXTCLOUD_HTTPS_PORT=${NEXTCLOUD_HTTPS_PORT}
  echo VAULTWARDEN_HTTPS_PORT=${VAULTWARDEN_HTTPS_PORT}
  echo VAULTWARDEN_ROCKET_PORT=${VAULTWARDEN_ROCKET_PORT}
}

function installCaddy() {
  CreatePodmanNetwork
  CreateQuadletCaddy
  postInstall
  showStatus
}


function usage() {
  echo "##################"
  echo "Parameters available"
  echo "-c <path-to-config-file> (required) "
  echo "-i to install Nextcloud"
  echo "-u to uninstall Nextcloud"
  echo "-s to show status of Nextcloud services"
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
     echo "installing"
     installCaddy ;;
   "UNINSTALL")
     echo "uninstalling"
     uninstallCaddy ;;
   "STATUS")
     echo "showing status"
     showStatus ;;
   * )
     echo "Invalid Installation mode specified specifed us either -c or -u parameter"
     usage; 
     exit 1
     ;;
 esac    



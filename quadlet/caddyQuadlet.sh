#!/bin/bash
set -euo pipefail
source /links/bin/lib/quadletFunctions.sh

function CreateCaddyFile() {
if [ -f ${CADDYFILE} ]; then
  echo "CADDYFILE ${CADDYFILE} exists"
  return
fi
if [ ${INTERNAL_TLS} != "true" ]; then
  TLS_CONFIG="# tls internal"
else
  TLS_CONFIG="tls internal"
fi  
  mkdir -p $(dirname ${CADDYFILE})
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
  ${TLS_CONFIG}

  # Change below to host IP
  reverse_proxy ${SERVER_IP}:${NEXTCLOUD_HTTP_PORT}
}

${CADDY_PROXY_DOMAIN}:${VAULTWARDEN_HTTPS_PORT} {
	reverse_proxy ${SERVER_IP}:${VAULTWARDEN_ROCKET_PORT}
  # for local testing uncomment the following line
  ${TLS_CONFIG}
}
EOF
}

function CreateQuadlet() {
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
PublishPort=80:80 # required for acme challenge which needs to run every other month
PublishPort=${NEXTCLOUD_HTTP_PORT}:${NEXTCLOUD_HTTP_PORT}
PublishPort=${NEXTCLOUD_HTTPS_PORT}:${NEXTCLOUD_HTTPS_PORT}
PublishPort=${VAULTWARDEN_HTTPS_PORT}:${VAULTWARDEN_HTTPS_PORT}
Volume=${CADDYFILE}:/etc/caddy/Caddyfile:z
Volume=${DATA_DIR}/data:/data:Z
Volume=${NEXTCLOUD_DATA_DIR}/html:/var/www/html:ro,z
AddCapability=CAP_AUDIT_WRITE

[Install]
${START_ON_BOOT}
EOF
}

function postInstall() {
  ${SYSTEMCTL_CMD} daemon-reload
  ${SYSTEMCTL_CMD} start ${SERVICE_NAME}.service
  # for local development enable this
  #  if [[ $(id -u) -eq 0 ]] ; then 
  #  cp ${DATA_DIR}/data/caddy/pki/authorities/local/root.crt /etc/pki/ca-trust/source/anchors/caddy-root-ca.crt
  #  update-ca-trust
  # fi  
}

function install() {
  CreatePodmanNetwork
  CreateCaddyFile
  CreateQuadlet
  postInstall
  showStatus
}

function setEnvVars() {
  setDefaultEnvVars
  SERVICE_NAME="caddy"
  CADDYFILE="$(yq -r '.CADDY.CADDYFILE' ${CONFIG_YAML})"
  CADDY_PROXY_DOMAIN="$(yq -r '.CADDY.PROXY_DOMAIN' ${CONFIG_YAML})"
  DATA_DIR="$(yq -r '.CADDY.DATA_DIR' ${CONFIG_YAML})"
  NEXTCLOUD_DATA_DIR="$(yq -r '.NEXTCLOUD.DATA_DIR' ${CONFIG_YAML})"
  SERVER_IP=$(hostname -I | awk '{print $1}')
  NEXTCLOUD_HTTP_PORT="$(yq -r '.NEXTCLOUD.HTTP_PORT' ${CONFIG_YAML})"
  NEXTCLOUD_HTTPS_PORT="$(yq -r '.NEXTCLOUD.HTTPS_PORT' ${CONFIG_YAML})"
  VAULTWARDEN_HTTPS_PORT="$(yq -r '.VAULTWARDEN.HTTPS_PORT' ${CONFIG_YAML})"
  VAULTWARDEN_ROCKET_PORT="$(yq -r '.VAULTWARDEN.ROCKET_PORT' ${CONFIG_YAML})"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' ${CONFIG_YAML})"
  CONTAINER_IMAGE="$(yq -r '.CADDY.CONTAINER_IMAGE' "${CONFIG_YAML}")" 
  START_ON_BOOT="$(yq -r '.CADDY.START_ON_BOOT' "${CONFIG_YAML}")" 
  INTERNAL_TLS="$(yq -r '.CADDY.INTERNAL_TLS' "${CONFIG_YAML}")" 
  NUM_BACKUPS=3
}


function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo SERVER_IP=${SERVER_IP}
  echo CADDY_PROXY_DOMAIN=${CADDY_PROXY_DOMAIN}
  echo CADDYFILE=${CADDYFILE}
  echo DATA_DIR=${DATA_DIR}
  echo NEXTCLOUD_DATA_DIR=${NEXTCLOUD_DATA_DIR}
  echo NEXTCLOUD_HTTP_PORT=${NEXTCLOUD_HTTP_PORT}
  echo NEXTCLOUD_HTTPS_PORT=${NEXTCLOUD_HTTPS_PORT}
  echo VAULTWARDEN_HTTPS_PORT=${VAULTWARDEN_HTTPS_PORT}
  echo VAULTWARDEN_ROCKET_PORT=${VAULTWARDEN_ROCKET_PORT}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo START_ON_BOOT=${START_ON_BOOT}
  echo INTERNAL_TLS=${INTERNAL_TLS}
}

main "$@"

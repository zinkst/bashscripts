#!/bin/bash

# inspired by https://codeberg.org/mjack/nextcloud-quadlets.git

set -euo pipefail

# TEST_MODE="false"

# function run-cmd () {
#   if [ ${TEST_MODE} == "false" ]; then
# 		eval "${1}"
# 	else
# 	  echo "${1}"
# 	fi	
# }

function createDirs() {
  mkdir -p ${QUADLET_DIR}
  mkdir -p ${NEXTCLOUD_ROOT_DIR}
  mkdir -p ${NEXTCLOUD_ROOT_DIR}/{db,html}
  mkdir -p ${NEXTCLOUD_DATA_DIR}
  mkdir -p ${QUADLET_DIR}
}

function createPrereqs() {
  printf "${MARIADB_USER_PASSWORD}" | podman secret create --replace mysql-password -
  printf "${MARIADB_ROOT_PASSWORD}" | podman secret create --replace mysql-root-password -
  printf "${NEXTCLOUD_ADMIN_PASSWORD}" | podman secret create --replace nextcloud-admin-password -
  if ! grep -qF 'alias occ=' ~/.profile; then
    echo "alias occ='podman exec -it -u www-data nextcloud-app php occ'" >> ~/.profile
  fi
}

function CreateQuadletNextcloudApp() {
  cat <<EOF > ${QUADLET_DIR}/nextcloud-app.container 
[Unit]
Description=Nextcloud App
Requires=nextcloud-db.service
After=nextcloud-db.service

[Container]
Label=app=nextcloud
AutoUpdate=registry
Pod=nextcloud.pod
ContainerName=nextcloud-app
Image=docker.io/library/nextcloud:fpm-alpine
Network=${NETWORK_NAME}
Volume=${NEXTCLOUD_DATA_DIR}:/var/www/html/data:Z
Volume=${NEXTCLOUD_ROOT_DIR}/html:/var/www/html/:Z
Volume=${NEXTCLOUD_EXTERNAL_DATA_DIR}:${NEXTCLOUD_EXTERNAL_DATA_DIR}:Z
Environment=MYSQL_HOST=nextcloud-db
Environment=MYSQL_DATABASE=${MARIADB_DATABASE_NAME}
Environment=MYSQL_USER=${MARIADB_USER}
Environment=NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER}
Secret=mysql-password,type=env,target=MYSQL_PASSWORD
Secret=nextcloud-admin-password,type=env,target=NEXTCLOUD_ADMIN_PASSWORD
Environment=REDIS_HOST=nextcloud-redis
# RemapUsers=host

[Install]
WantedBy=default.target
EOF
}

function CreateQuadletNextcloudDb() {
  cat <<EOF > ${QUADLET_DIR}/nextcloud-db.container 
[Unit]
Description=Nextcloud Database

[Container]
Pod=nextcloud.pod
Label=app=nextcloud
AutoUpdate=registry
ContainerName=nextcloud-db
Image=docker.io/library/mariadb:10.6
Network=${NETWORK_NAME}
Volume=${NEXTCLOUD_ROOT_DIR}/db:/var/lib/mysql:Z
Environment=MARIADB_AUTO_UPGRADE=1
Environment=MARIADB_DISABLE_UPGRADE_BACKUP=1
Environment=MARIADB_DATABASE=${MARIADB_DATABASE_NAME}
Environment=MARIADB_USER=${MARIADB_USER}
Secret=mysql-password,type=env,target=MARIADB_PASSWORD
Secret=mysql-root-password,type=env,target=MARIADB_ROOT_PASSWORD
# RemapUsers=host

[Install]
WantedBy=default.target
RequiredBy=nextcloud-app.service
EOF
}

function CreateQuadletCaddy() {
  mkdir -p ${NEXTCLOUD_ROOT_DIR}/caddy/data
  cat <<EOF > ${CADDYFILE}
:80 {
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

${CADDY_PROXY_DOMAIN} {
    redir /.well-known/carddav /remote.php/dav/ 301
    redir /.well-known/caldav /remote.php/dav/ 301

    header {
        Strict-Transport-Security max-age=31536000;
    }

    # Change below to host IP
    reverse_proxy ${SERVER_IP}:80
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
AutoUpdate=registry
ContainerName=caddy
Image=docker.io/caddy:latest
Network=${NETWORK_NAME}
PublishPort=80:80
PublishPort=9443:443
Volume=${CADDYFILE}:/etc/caddy/Caddyfile:z
Volume=${NEXTCLOUD_ROOT_DIR}/caddy/data:/data:Z
Volume=${NEXTCLOUD_ROOT_DIR}/html:/var/www/html:ro,z
AddCapability=CAP_AUDIT_WRITE

[Install]
WantedBy=default.target
EOF
}

function CreateNextcloudCronJobTimer() {
  cat <<EOF > ${SYSTEMD_UNIT_DIR}/nextcloud-cron.service
[Unit]
Description=Nextcloud Cron Service
After=network.target

[Service]
Type=oneshot
ExecStart=podman  exec -t -u www-data nextcloud-app php -f /var/www/html/cron.php

[Install]
WantedBy=default.target
EOF

  cat <<EOF > ${SYSTEMD_UNIT_DIR}/nextcloud-cron.timer
[Unit]
Description=Run  Nextcloud Cron Service every 30 minutes

[Timer]
OnBootSec=3min
OnUnitActiveSec=5min

[Install]
WantedBy=timers.target
EOF
}

function CreateQuadletNextcloudRedis() {
  cat <<EOF > ${QUADLET_DIR}/nextcloud-redis.container 
[Unit]
Description=Nextcloud Redis

[Container]
Pod=nextcloud.pod
Label=app=nextcloud
AutoUpdate=registry
ContainerName=nextcloud-redis
Image=docker.io/library/redis:alpine
Network=${NETWORK_NAME}

[Install]
WantedBy=nextcloud-app.service default.target
EOF
}

function CreateUnitNextcloudNetwork() {
podman network create ${NETWORK_NAME} --ignore
#   cat <<EOF > ${QUADLET_DIR}/${NETWORK_NAME}.network
# [Unit]
# Description=${NETWORK_NAME} Network

# [Network]
# # Label=app=nextcloud
# DisableDNS=false
# NetworkName=${NETWORK_NAME}
# EOF
}

function CreateUnitNextcloudPod() {
  cat <<EOF > ${QUADLET_DIR}/nextcloud.pod
[Unit]
Description=Nextcloud Pod

[Pod]
PodName=nextcloud
Network=${NETWORK_NAME}
EOF
}

function postInstall() {
  ${SYSTEMCTL_CMD} daemon-reload
  ${SYSTEMCTL_CMD} enable --now podman-auto-update.timer
  ${SYSTEMCTL_CMD} start nextcloud-pod.service
  if [ ${INSTALL_CADDY} == "true" ]; then
    ${SYSTEMCTL_CMD} start caddy.service
  fi  
  ${SYSTEMCTL_CMD} enable --now nextcloud-cron.timer
  ${SYSTEMCTL_CMD} --no-pager status nextcloud-pod.service
  if [[ $(id -u) -ne 0 ]] ; then 
    loginctl enable-linger $USER
  fi 

  # sudo chown -R 100998:100997 ${NEXTCLOUD_ROOT_DIR}/db
}

function configureNextcloud() {
  alias occ='podman exec -it -u www-data nextcloud-app php occ'
  ${BASH_ALIASES[occ]} config:system:set trusted_domains 1 --value=${SERVER_IP}
  ${BASH_ALIASES[occ]} config:system:set trusted_domains 2 --value=${CADDY_PROXY_DOMAIN}
  ${BASH_ALIASES[occ]} config:system:set trusted_proxies 0 --value=${SERVER_IP}
  ${BASH_ALIASES[occ]} app:enable files_external
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.stefan.password' ${CONFIG_YAML})
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Stefan Zink" --group="burghalde" stefan 
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.marion.password' ${CONFIG_YAML})
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Marion Zink" --group="burghalde" marion 
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.georg.password' ${CONFIG_YAML})
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Georg Zink" --group="burghalde" georg 
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.henry.password' ${CONFIG_YAML})
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Henry Zink" --group="burghalde" henry 
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.valentin.password' ${CONFIG_YAML})
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Valentin Zink" --group="burghalde" valentin 
}

function uninstallNextcloud() {
  ${SYSTEMCTL_CMD} disable --now podman-auto-update.timer
  ${SYSTEMCTL_CMD} stop nextcloud-pod.service
  if [[ $(id -u) -ne 0 ]] ; then 
    loginctl disable-linger $USER
  fi 
  for  i in ${!QUADLETS[@]}; do
        echo "removing quadlet ${QUADLETS[$i]}"
        cmd="rm ${QUADLET_DIR}/${QUADLETS[$i]}"
        echo "${cmd}"
        eval "${cmd}"
  done
  ${SYSTEMCTL_CMD} disable --now nextcloud-cron.timer
  if [ ${INSTALL_CADDY} == "true" ]; then
    ${SYSTEMCTL_CMD} stop caddy.service
    rm ${QUADLET_DIR}/caddy.container
  fi  
  rm ${SYSTEMD_UNIT_DIR}/nextcloud-cron.timer
  rm ${SYSTEMD_UNIT_DIR}/nextcloud-cron.service
  podman secret rm mysql-password
  podman secret rm mysql-root-password
  podman secret rm nextcloud-admin-password
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
  NEXTCLOUD_ROOT_DIR="$(yq -r '.NEXTCLOUD.ROOT_DIR' ${CONFIG_YAML})"
  NEXTCLOUD_DATA_DIR="$(yq -r '.NEXTCLOUD.DATA_DIR' ${CONFIG_YAML})"
  NEXTCLOUD_EXTERNAL_DATA_DIR="$(yq -r '.NEXTCLOUD.EXTERNAL_DATA_DIR' ${CONFIG_YAML})"
  NEXTCLOUD_ADMIN_USER="$(yq -r '.NEXTCLOUD.ADMIN_USER' ${CONFIG_YAML})"
  NEXTCLOUD_ADMIN_PASSWORD="$(yq -r '.NEXTCLOUD.ADMIN_PASSWORD' ${CONFIG_YAML})"
  MARIADB_DATABASE_NAME="$(yq -r '.MARIADB.DATABASE_NAME' ${CONFIG_YAML})"
  MARIADB_USER="$(yq -r '.MARIADB.USER' ${CONFIG_YAML})"
  MARIADB_USER_PASSWORD="$(yq -r '.MARIADB.USER_PASSWORD' ${CONFIG_YAML})"
  MARIADB_ROOT_PASSWORD="$(yq -r '.MARIADB.ROOT_PASSWORD' ${CONFIG_YAML})"
  INSTALL_CADDY="$(yq -r '.CADDY.INSTALL' ${CONFIG_YAML})"
  if [ ${INSTALL_CADDY} == "true" ]; then
    CADDYFILE=${NEXTCLOUD_ROOT_DIR}/caddy/caddyfile
    CADDY_PROXY_DOMAIN="$(yq -r '.CADDY.PROXY_DOMAIN' ${CONFIG_YAML})"
  fi  
  SERVER_IP=$(hostname -I | awk '{print $1}')
  QUADLETS=(
    nextcloud-app.container
    nextcloud-db.container
    nextcloud-redis.container
    nextcloud.pod
  )
}


function showStatus() {
  SERVICES=(
    nextcloud-app
    nextcloud-db
    nextcloud-redis
  )
  if [ ${INSTALL_CADDY} == "true" ]; then
    SERVICES+=("caddy")
  fi  
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
  echo NEXTCLOUD_ROOT_DIR=${NEXTCLOUD_ROOT_DIR}
  echo NEXTCLOUD_DATA_DIR=${NEXTCLOUD_DATA_DIR}
  echo NEXTCLOUD_EXTERNAL_DATA_DIR=${NEXTCLOUD_EXTERNAL_DATA_DIR}
  echo NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER}
  echo MARIADB_DATABASE_NAME=${MARIADB_DATABASE_NAME}
  echo MARIADB_USER=${MARIADB_USER}
  echo NETWORK_NAME=${NETWORK_NAME}
  echo INSTALL_CADDY=${INSTALL_CADDY}
  if [ ${INSTALL_CADDY} == "true" ]; then
    echo CADDY_PROXY_DOMAIN=${CADDY_PROXY_DOMAIN}
    echo CADDYFILE=${CADDYFILE}
  fi  
  echo SERVER_IP=${SERVER_IP}
}

function installNextcloud() {
  createDirs
  createPrereqs
  CreateUnitNextcloudPod
  CreateUnitNextcloudNetwork
  CreateQuadletNextcloudRedis
  CreateQuadletNextcloudDb
  CreateQuadletNextcloudApp
  CreateNextcloudCronJobTimer
  if [ ${INSTALL_CADDY} == "true" ]; then
    CreateQuadletCaddy
  fi  
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
     echo "installing nextcloud"
     installNextcloud ;;
   "UNINSTALL")
     echo "uninstalling nextcloud"
     uninstallNextcloud ;;
   "STATUS")
     echo "showing status nextcloud"
     showStatus ;;
   * )
     echo "Invalid Installation mode specified specifed us either -c or -u parameter"
     usage; 
     exit 1
     ;;
 esac    



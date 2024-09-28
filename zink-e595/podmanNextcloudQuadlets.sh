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
  mkdir -p ${NEXTCLOUD_ROOT_DIR}/{db,,caddy/data,html}
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
Network=nextcloud.network
Volume=${NEXTCLOUD_DATA_DIR}:/var/www/html/data:Z
Volume=${NEXTCLOUD_ROOT_DIR}/html:/var/www/html/:Z
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
Network=nextcloud.network
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
Network=nextcloud.network
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
OnUnitActiveSec=30min

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
Network=nextcloud.network

[Install]
WantedBy=nextcloud-app.service default.target
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
Network=nextcloud.network

[Install]
WantedBy=nextcloud-app.service default.target
EOF
}

function CreateUnitNextcloudNetwork() {
  cat <<EOF > ${QUADLET_DIR}/nextcloud.network 
[Unit]
Description=Nextcloud Network

[Network]
Label=app=nextcloud
DisableDNS=false
EOF
}

function CreateUnitNextcloudPod() {
  cat <<EOF > ${QUADLET_DIR}/nextcloud.pod
[Unit]
Description=Nextcloud Pod

[Pod]
PodName=nextcloud
Network=nextcloud.network
EOF
}

function postInstall() {
  systemctl --user daemon-reload
  systemctl --user enable --now podman-auto-update.timer
  systemctl --user start nextcloud-pod.service
  systemctl --user start caddy.service
  systemctl --user enable --now nextcloud-cron.timer
  systemctl --user --no-pager status nextcloud-pod.service
  loginctl enable-linger $USER
}

function configureNextcloud() {
  alias occ='podman exec -it -u www-data nextcloud-app php occ'
  ${BASH_ALIASES[occ]} config:system:set trusted_domains 1 --value=${SERVER_IP}
  ${BASH_ALIASES[occ]} config:system:set trusted_domains 2 --value=${CADDY_PROXY_DOMAIN}
  ${BASH_ALIASES[occ]} config:system:set trusted_proxies 0 --value=${SERVER_IP}
  
  OC_PASS=$(yq -r '.USERS.stefan.password' ${CONFIG_YAML})
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Stefan Zink" --group="burghalde" stefan 
  OC_PASS=$(yq -r '.USERS.marion.password' ${CONFIG_YAML})
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Marion Zink" --group="burghalde" marion 
}

function setEnvVars() {
  export QUADLET_DIR=${HOME}/.config/containers/systemd/
  export SYSTEMD_UNIT_DIR=${HOME}/.config/systemd/user/
  export CONFIG_YAML="${HOME}/Gemeinsam/Burghalde/HeimNetz/Nextcloud-quadlet/config-$(hostname -s).yml"
  NEXTCLOUD_ROOT_DIR="$(yq -r '.NEXTCLOUD.ROOT_DIR' ${CONFIG_YAML})"
  NEXTCLOUD_DATA_DIR="$(yq -r '.NEXTCLOUD.DATA_DIR' ${CONFIG_YAML})"
  NEXTCLOUD_ADMIN_USER="$(yq -r '.NEXTCLOUD.ADMIN_USER' ${CONFIG_YAML})"
  NEXTCLOUD_ADMIN_PASSWORD="$(yq -r '.NEXTCLOUD.ADMIN_PASSWORD' ${CONFIG_YAML})"
  export CADDYFILE=${NEXTCLOUD_ROOT_DIR}/caddy/caddyfile
  MARIADB_DATABASE_NAME="$(yq -r '.MARIADB.DATABASE_NAME' ${CONFIG_YAML})"
  MARIADB_USER="$(yq -r '.MARIADB.USER' ${CONFIG_YAML})"
  MARIADB_USER_PASSWORD="$(yq -r '.MARIADB.USER_PASSWORD' ${CONFIG_YAML})"
  MARIADB_ROOT_PASSWORD="$(yq -r '.MARIADB.ROOT_PASSWORD' ${CONFIG_YAML})"
  CADDY_PROXY_DOMAIN="$(yq -r '.CADDY.PROXY_DOMAIN' ${CONFIG_YAML})"
  SERVER_IP=$(hostname -I | awk '{print $1}')
}

function printEnvVars() {
  echo CONFIG_YAML=${CONFIG_YAML}
  echo NEXTCLOUD_ROOT_DIR=${NEXTCLOUD_ROOT_DIR}
  echo NEXTCLOUD_DATA_DIR=${NEXTCLOUD_DATA_DIR}
  echo NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER}
  echo MARIADB_DATABASE_NAME=${MARIADB_DATABASE_NAME}
  echo MARIADB_USER=${MARIADB_USER}
  echo CADDY_PROXY_DOMAIN=${CADDY_PROXY_DOMAIN}
  echo CADDYFILE_PROXY=${CADDYFILE_PROXY}
  echo CADDYFILE_WEB=${CADDYFILE_WEB}
  echo SERVER_IP=${SERVER_IP}
}

setEnvVars
printEnvVars
# createDirs
# createPrereqs
# CreateUnitNextcloudPod
# CreateUnitNextcloudNetwork
# CreateQuadletNextcloudRedis
# CreateQuadletCaddyWeb
# CreateQuadletCaddyProxy
# CreateQuadletCaddy
# CreateQuadletNextcloudDb
# CreateQuadletNextcloudApp
# postInstall
# sleep 50
# configureNextcloud
# CreateNextcloudCronJobTimer

#!/bin/bash

# inspired by https://codeberg.org/mjack/nextcloud-quadlets.git
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function createDirs() {
  mkdir -p ${DATA_DIR}
  mkdir -p ${DATA_DIR}/{db,html}
  mkdir -p ${QUADLET_DIR}
  mkdir -p ${NC_DATA_DIR}
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
if [ -f "${QUADLET_DIR}/nextcloud-app.container" ]; then
  echo "File ${QUADLET_DIR}/nextcloud-app.container exists"
  return
fi
  
  cat <<EOF > ${QUADLET_DIR}/nextcloud-app.container 
[Unit]
Description=Nextcloud App
Requires=nextcloud-db.service
After=nextcloud-db.service

[Container]
Label=app=nextcloud
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
Pod=nextcloud.pod
ContainerName=nextcloud-app
Image=${NEXTCLOUD_IMAGE}
Network=${NETWORK_NAME}
Volume=${NC_DATA_DIR}:/var/www/html/data:Z
Volume=${DATA_DIR}/html:/var/www/html/:Z
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
if [ -f "${QUADLET_DIR}/nextcloud-db.container" ]; then
  echo "File ${QUADLET_DIR}/nextcloud-db.container exists"
  return
fi
  cat <<EOF > ${QUADLET_DIR}/nextcloud-db.container 
[Unit]
Description=Nextcloud Database

[Container]
Pod=nextcloud.pod
Label=app=nextcloud
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=nextcloud-db
Image=${MARIADB_IMAGE}
Network=${NETWORK_NAME}
Volume=${DATA_DIR}/db:/var/lib/mysql:Z
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
  mkdir -p "${CADDY_DATA_DIR}/data"
if [ -f "${QUADLET_DIR}/nextcloud-app.container" ]; then
  echo "File ${QUADLET_DIR}/nextcloud-app.container exists"
  return
fi
  cat <<EOF > ${CADDYFILE}
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
    tls internal
    header {
        Strict-Transport-Security max-age=31536000;
    }

    # Change below to host IP
    reverse_proxy ${SERVER_NAME}:${NEXTCLOUD_HTTP_PORT}
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
Image=${CADDY_IMAGE}
Network=${NETWORK_NAME}
PublishPort=${NEXTCLOUD_HTTP_PORT}:${NEXTCLOUD_HTTP_PORT}
PublishPort=${NEXTCLOUD_HTTPS_PORT}:${NEXTCLOUD_HTTPS_PORT}
Volume=${CADDYFILE}:/etc/caddy/Caddyfile:z
Volume=${CADDY_DATA_DIR}/data:/data:Z
Volume=${DATA_DIR}/html:/var/www/html:ro,z
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
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=nextcloud-redis
Image=${REDIS_IMAGE}
Network=${NETWORK_NAME}

[Install]
WantedBy=nextcloud-app.service default.target
EOF
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

function backup () {
   source /links/bin/lib/dbBackupFunctions.sh
   BACKUP_DIR="/links/sysbkp/nextcloud-quadlet"
   export NUM_BACKUPS=${NUM_BACKUPS:-3}
   START_SERVICE_AFTER_BACKUP="false"
   if [ "$(${SYSTEMCTL_CMD} is-active nextcloud-pod.service)" == "active" ]; then
     START_SERVICE_AFTER_BACKUP="true"
     CMD="podman exec -it -u www-data nextcloud-app php occ maintenance:mode --on" 
     run-cmd "${CMD}"
   fi
   echo "creating backup of nextcloud html "
   initDirWithBackupFiles "nextcloud_html.tgz"
   rotateFiles "nextcloud_html.tgz"
   CMD="tar -czf  ${BACKUP_DIR}/nextcloud_html.tgz --directory ${DATA_DIR}/html ."
   run-cmd "${CMD}"
   echo "creating mariadbdump backup of nextcloud db "
   initDirWithBackupFiles "mariadb_dump.sql.gz"
   rotateFiles "mariadb_dump.sql.gz"
   CMD="podman exec -it nextcloud-db mariadb-dump -u ${MARIADB_USER} -p${MARIADB_USER_PASSWORD} ${MARIADB_DATABASE_NAME} | gzip -9 > ${BACKUP_DIR}/mariadb_dump.sql.gz"
   run-cmd "${CMD}"
   #  CMD="echo Waiting 60 seconds && sleep 60" # doesn't prevent  tar: ./ib_logfile0: Datei hat sich beim Lesen geändert in next call
   #  run-cmd "${CMD}"
   echo "creating backup of nextcloud db data volume"
   initDirWithBackupFiles "nextcloud_db.tgz"
   rotateFiles "nextcloud_db.tgz"
   CMD="tar -czf  ${BACKUP_DIR}/nextcloud_db.tgz --directory ${DATA_DIR}/db . || true"
   run-cmd "${CMD}"
   if [ "${START_SERVICE_AFTER_BACKUP}" == "true" ]; then
    CMD="podman exec -it -u www-data nextcloud-app php occ maintenance:mode --off" 
    run-cmd "${CMD}"
   fi 
   echo "finished Backup of ${SERVICE_NAME}"
   createBackupService
   createBackupTimer
}	

function restore () {
   CMD="systemctl stop nextcloud-pod.service"
   run-cmd "${CMD}"
   echo "restoring backup of nextcloud html "
   CMD="mv ${DATA_DIR}/html ${DATA_DIR}/html_$(date +'%y%m%d_%H%M%S')"
   run-cmd "${CMD}"
   CMD="mkdir -p ${DATA_DIR}/html"
   run-cmd "${CMD}"
   CMD="tar -xzf  ${BACKUP_DIR}/nextcloud_html.tgz --directory ${DATA_DIR}/html"
   run-cmd "${CMD}"
   # restore of DB seems to be not necessary restoreing the db volume is sufficient
   #  echo "creating mariadbdump backup of nextcloud db "
   #  CMD="podman exec -it nextcloud-db mariadb-dump -u ${MARIADB_USER} -p${MARIADB_USER_PASSWORD} ${MARIADB_DATABASE_NAME} | gzip -9 > ${BACKUP_DIR}/mariadb_dump.sql.gz"
   #  run-cmd "${CMD}"
   echo "restoring backup of nextcloud db data volume"
   CMD="mv ${DATA_DIR}/db ${DATA_DIR}/db_$(date +'%y%m%d_%H%M%S')"
   run-cmd "${CMD}"
   CMD="mkdir -p ${DATA_DIR}/db"
   run-cmd "${CMD}"
   CMD="tar -xzf  ${BACKUP_DIR}/nextcloud_db.tgz --directory ${DATA_DIR}/db"
   run-cmd "${CMD}"
   echo "Starting nextcloud pods from backup"
   CMD="systemctl start nextcloud-pod.service" 
   run-cmd "${CMD}"
   CMD="echo Waiting 60 seconds && sleep 60" 
   run-cmd "${CMD}"
   # need to disable maintenance mode since nextcloud was in mainteance mode when backup was created
   echo "Disabling maintenance mode" 
   CMD="podman exec -it -u www-data nextcloud-app php occ maintenance:mode --off" 
   run-cmd "${CMD}"
}	

function postInstall() {
  ${SYSTEMCTL_CMD} daemon-reload
  # ${SYSTEMCTL_CMD} enable --now podman-auto-update.timer
  ${SYSTEMCTL_CMD} start nextcloud-pod.service
  if [ ${INSTALL_CADDY} == "true" ]; then
    ${SYSTEMCTL_CMD} start caddy.service
  fi  
  ${SYSTEMCTL_CMD} enable --now nextcloud-cron.timer
  ${SYSTEMCTL_CMD} --no-pager status nextcloud-pod.service
  if [[ $(id -u) -ne 0 ]] ; then 
    loginctl enable-linger $USER
  fi 
  # sudo chown -R 100998:100997 ${DATA_DIR}/db
}

function configureNextcloud() {
  alias occ='podman exec -it -u www-data nextcloud-app php occ'
  ${BASH_ALIASES[occ]} config:system:set trusted_domains 1 --value=${SERVER_NAME}:${NEXTCLOUD_HTTP_PORT}
  ${BASH_ALIASES[occ]} config:system:set trusted_domains 2 --value=${CADDY_PROXY_DOMAIN}:${NEXTCLOUD_HTTPS_PORT}
  ${BASH_ALIASES[occ]} config:system:set trusted_proxies 0 --value=${SERVER_IP}
  ${BASH_ALIASES[occ]} config:system:set overwriteprotocol --value 'https'
  ${BASH_ALIASES[occ]} app:enable files_external
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.stefan.password' "${CONFIG_YAML}")
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Stefan Zink" --group="burghalde" stefan 
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.marion.password' "${CONFIG_YAML}")
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Marion Zink" --group="burghalde" marion 
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.georg.password' "${CONFIG_YAML}")
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Georg Zink" --group="burghalde" georg 
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.henry.password' "${CONFIG_YAML}")
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Henry Zink" --group="burghalde" henry 
  OC_PASS=$(yq -r '.NEXTCLOUD.USERS.valentin.password' "${CONFIG_YAML}")
  podman exec -it -u www-data -e OC_PASS="${OC_PASS}" nextcloud-app php occ user:add --password-from-env --display-name="Valentin Zink" --group="burghalde" valentin 
}

function remove() {
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
  rm ${SYSTEMD_UNIT_DIR}/backup-nextcloud.timer
  rm ${SYSTEMD_UNIT_DIR}/backup-nextcloud.service
  podman secret rm mysql-password
  podman secret rm mysql-root-password
  podman secret rm nextcloud-admin-password
}

function setEnvVars() {
  setDefaultEnvVars
  SERVICE_NAME="nextcloud"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  DATA_DIR="$(yq -r '.NEXTCLOUD.DATA_DIR' "${CONFIG_YAML}")"
  NC_DATA_DIR="$(yq -r '.NEXTCLOUD.NC_DATA_DIR' "${CONFIG_YAML}")"
  NEXTCLOUD_EXTERNAL_DATA_DIR="$(yq -r '.NEXTCLOUD.EXTERNAL_DATA_DIR' "${CONFIG_YAML}")"
  NEXTCLOUD_ADMIN_USER="$(yq -r '.NEXTCLOUD.ADMIN_USER' "${CONFIG_YAML}")"
  NEXTCLOUD_ADMIN_PASSWORD="$(yq -r '.NEXTCLOUD.ADMIN_PASSWORD' "${CONFIG_YAML}")"
  NEXTCLOUD_HTTP_PORT="$(yq -r '.NEXTCLOUD.HTTP_PORT' "${CONFIG_YAML}")"
  NEXTCLOUD_HTTPS_PORT="$(yq -r '.NEXTCLOUD.HTTPS_PORT' "${CONFIG_YAML}")"
  NEXTCLOUD_IMAGE="$(yq -r '.NEXTCLOUD.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  MARIADB_DATABASE_NAME="$(yq -r '.MARIADB.DATABASE_NAME' "${CONFIG_YAML}")"
  MARIADB_USER="$(yq -r '.MARIADB.USER' "${CONFIG_YAML}")"
  MARIADB_USER_PASSWORD="$(yq -r '.MARIADB.USER_PASSWORD' "${CONFIG_YAML}")"
  MARIADB_ROOT_PASSWORD="$(yq -r '.MARIADB.ROOT_PASSWORD' "${CONFIG_YAML}")"
  MARIADB_IMAGE="$(yq -r '.MARIADB.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  CADDY_PROXY_DOMAIN="$(yq -r '.CADDY.PROXY_DOMAIN' "${CONFIG_YAML}")"
  INSTALL_CADDY="$(yq -r '.NEXTCLOUD.INSTALL_CADDY' "${CONFIG_YAML}")"
  if [ ${INSTALL_CADDY} == "true" ]; then
    CADDYFILE="$(yq -r '.CADDY.CADDYFILE' "${CONFIG_YAML}")"
    CADDY_DATA_DIR="$(yq -r '.CADDY.DATA_DIR' "${CONFIG_YAML}")"
    CADDY_IMAGE="$(yq -r '.CADDY.CONTAINER_IMAGE' "${CONFIG_YAML}")"
  fi  
  SERVER_IP=$(hostname -I | awk '{print $1}')
  SERVER_NAME=$(hostname -s)
  REDIS_IMAGE="$(yq -r '.REDIS.CONTAINER_IMAGE' "${CONFIG_YAML}")"
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
        echo "### Status for service ${SERVICES[$i]}:" $(${SYSTEMCTL_CMD} --no-pager is-active  ${SERVICES[$i]})
  done
}

function update() {
  cmd="${SYSTEMCTL_CMD} stop nextcloud-pod.service"
  run-cmd "${cmd}"
  updateComponent "${MARIADB_IMAGE}" "nextcloud-db" "false"
  updateComponent "${NEXTCLOUD_IMAGE}" "nextcloud-app" "false"
  updateComponent "${REDIS_IMAGE}" "nextcloud-redis" "false"
  cmd="${SYSTEMCTL_CMD} daemon-reload"
  run-cmd "${cmd}"
  cmd="${SYSTEMCTL_CMD} start nextcloud-pod.service"
  run-cmd "${cmd}"
  showStatus
}

function printEnvVars() {
  printDefaultEnvVars
  echo DATA_DIR=${DATA_DIR}
  echo NC_DATA_DIR=${NC_DATA_DIR}
  echo NEXTCLOUD_EXTERNAL_DATA_DIR=${NEXTCLOUD_EXTERNAL_DATA_DIR}
  echo NEXTCLOUD_ADMIN_USER=${NEXTCLOUD_ADMIN_USER}
  echo NEXTCLOUD_HTTP_PORT=${NEXTCLOUD_HTTP_PORT}
  echo NEXTCLOUD_IMAGE=${NEXTCLOUD_IMAGE}
  echo MARIADB_DATABASE_NAME=${MARIADB_DATABASE_NAME}
  echo MARIADB_USER=${MARIADB_USER}
  echo MARIADB_IMAGE=${MARIADB_IMAGE}
  echo NETWORK_NAME=${NETWORK_NAME}
  echo REDIS_IMAGE=${REDIS_IMAGE}
  echo INSTALL_CADDY=${INSTALL_CADDY}
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  if [ ${INSTALL_CADDY} == "true" ]; then
    echo CADDY_PROXY_DOMAIN=${CADDY_PROXY_DOMAIN}
    echo CADDYFILE=${CADDYFILE}
    echo CADDY_DATA_DIR=${CADDY_DATA_DIR}    
  fi  
  echo SERVER_IP=${SERVER_IP}
  echo SERVER_NAME=${SERVER_NAME}
}

function install() {
  createDirs
  createPrereqs
  CreateUnitNextcloudPod
  CreatePodmanNetwork
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


# main start here
main "$@"
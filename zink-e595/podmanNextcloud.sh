#!/bin/bash
export CONFIG_YAML="/local/data/$(hostname -s)/srv/nextcloud/config.yml"
NEXTCLOUD_ROOT_DIR="$(yq -r '.NEXTCLOUD.ROOT_DIR' ${CONFIG_YAML})"
NEXTCLOUD_DATA_DIR="$(yq -r '.NEXTCLOUD.DATA_DIR' ${CONFIG_YAML})"
export CADDYFILE=${NEXTCLOUD_ROOT_DIR}/caddy/caddyfile
export CONFIG_YAML=${NEXTCLOUD_ROOT_DIR}/config.yml
TEST_MODE="false"

function run-cmd () {
  if [ ${TEST_MODE} == "false" ]; then
		eval "${1}"
	else
	  echo "${1}"
	fi	
}


function createDirs() {
  mkdir ${NEXTCLOUD_ROOT_DIR}
  mkdir -p ${NEXTCLOUD_ROOT_DIR}/{db,caddy,html}
  mkdir -p ${NEXTCLOUD_ROOT_DIR}/caddy/caddy_data   # this removed an error for me running using podman 
}

function createCaddyfile() {
cat << EOF > $CADDYFILE
:80 {

        root * /var/www/html
        file_server

        php_fastcgi 127.0.0.1:9000

        redir /.well-known/carddav /remote.php/dav 301
        redir /.well-known/caldav /remote.php/dav 301

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

zinks.dnshome.de:9443 {
        encode gzip

        header Strict-Transport-Security max-age=15552000;
        reverse_proxy http://10.0.2.2:5080
}
EOF
}

function createPod() {
  cmd="podman pod create --network slirp4netns:port_handler=slirp4netns --hostname nextcloud --name nextcloud -p 5080:80/tcp"
  run-cmd "${cmd}"
}

function createMariaDBContainer() {
# cmd="podman run --detach --label 'io.containers.autoupdate=registry' \
#            --env MYSQL_ROOT_PASSWORD=\"$(yq -r '.MYSQL.ROOT_PASSWORD' ${CONFIG_YAML})\" \
#            --env MYSQL_DATABASE=\"$(yq -r '.MYSQL.DATABASE_NAME' ${CONFIG_YAML})\" \
#            --env MYSQL_USER=\"$(yq -r '.MYSQL.USER' ${CONFIG_YAML})\" \
#            --env MYSQL_PASSWORD=\"$(yq -r '.MYSQL.USER_PASSWORD' ${CONFIG_YAML})\" \
#            --volume \"${NEXTCLOUD_ROOT_DIR}/db\":/var/lib/mysql/:Z \
#            --pod nextcloud \
#            --restart on-failure \
#            --name nextcloud-db \
#            --transaction-isolation=READ-COMMITTED \
#            --log-bin=binlog \
#            --binlog-format=ROW \
#            docker.io/library/mariadb:10"
export cmd=$(cat <<EOF
podman run --detach --label 'io.containers.autoupdate=registry'
           --env MYSQL_ROOT_PASSWORD="$(yq -r '.MYSQL.ROOT_PASSWORD' ${CONFIG_YAML})"
           --env MYSQL_DATABASE="$(yq -r '.MYSQL.DATABASE_NAME' ${CONFIG_YAML})"
           --env MYSQL_USER="$(yq -r '.MYSQL.USER' ${CONFIG_YAML})"
           --env MYSQL_PASSWORD="$(yq -r '.MYSQL.USER_PASSWORD' ${CONFIG_YAML})"
           --volume "${NEXTCLOUD_ROOT_DIR}/db":/var/lib/mysql/:Z
           --pod nextcloud
           --restart on-failure
           --name nextcloud-db
           --transaction-isolation=READ-COMMITTED
           --log-bin=binlog
           --binlog-format=ROW
           docker.io/library/mariadb:10
EOF
)         
  run-cmd "${cmd}"
}

function createRedisContainer() {
  # cmd="podman run --detach \
  #                 --label "io.containers.autoupdate=registry"\
  #                 --restart on-failure \
  #                 --pod nextcloud \
  #                 --name nextcloud-redis \
  #                 --requirepass \"$(yq -r '.REDIS.PASSWORD' ${CONFIG_YAML})\" \
  #                 docker.io/library/redis:alpine \
  #                 redis-server"
  export cmd=$(cat <<EOF
  podman run --detach \
             --label "io.containers.autoupdate=registry"\
             --restart on-failure \
             --pod nextcloud \
             --name nextcloud-redis \
             --requirepass "$(yq -r '.REDIS.PASSWORD' ${CONFIG_YAML})" \
             docker.io/library/redis:alpine \
             redis-server
EOF
)             
run-cmd "${cmd}"
}

function createNextcloudContainer() {
  # cmd="podman run --detach \
  #                 --label "io.containers.autoupdate=registry" \
  #                 --env REDIS_HOST=\"127.0.0.1\" \
  #                 --env REDIS_HOST_PASSWORD=\"$(yq -r '.REDIS.PASSWORD' ${CONFIG_YAML})\" \
  #                 --env MYSQL_HOST=127.0.0.1 \
  #                 --env MYSQL_DATABASE=\"$(yq -r '.MYSQL.DATABASE_NAME' ${CONFIG_YAML})\" \
  #                 --env MYSQL_USER=\"$(yq -r '.MYSQL.USER' ${CONFIG_YAML})\" \
  #                 --env MYSQL_PASSWORD=\"$(yq -r '.MYSQL.USER_PASSWORD' ${CONFIG_YAML})\" \
  #                 --volume \"${NEXTCLOUD_ROOT_DIR}\"/html:/var/www/html/:z \
  #                 --volume \"${NEXTCLOUD_DATA_DIR}\":/var/www/html/data:z \
  #                 --pod nextcloud \
  #                 --restart on-failure \
  #                 --name nextcloud-app \
  #                 docker.io/library/nextcloud:fpm-alpine"
  export cmd=$(cat <<EOF
podman run --detach \
            --label "io.containers.autoupdate=registry" \
            --env REDIS_HOST="127.0.0.1" \
            --env REDIS_HOST_PASSWORD="$(yq -r '.REDIS.PASSWORD' ${CONFIG_YAML})" \
            --env MYSQL_HOST=127.0.0.1 \
            --env MYSQL_DATABASE="$(yq -r '.MYSQL.DATABASE_NAME' ${CONFIG_YAML})" \
            --env MYSQL_USER="$(yq -r '.MYSQL.USER' ${CONFIG_YAML})" \
            --env MYSQL_PASSWORD="$(yq -r '.MYSQL.USER_PASSWORD' ${CONFIG_YAML})" \
            --volume "${NEXTCLOUD_ROOT_DIR}"/html:/var/www/html/:z \
            --volume "${NEXTCLOUD_DATA_DIR}":/var/www/html/data:z \
            --pod nextcloud \
            --restart on-failure \
            --name nextcloud-app \
            docker.io/library/nextcloud:fpm-alpine
EOF
)                
  run-cmd "${cmd}"
}

function createCaddyContainer() {
  # cmd="podman run --detach \
  #                 --label "io.containers.autoupdate=registry" \
  #                 --volume \"${NEXTCLOUD_ROOT_DIR}\"/caddy/caddy_data:/data:Z \
  #                 --volume \"${CADDYFILE}\":/etc/caddy/Caddyfile:Z \
  #                 --volume \"${NEXTCLOUD_ROOT_DIR}\"/html:/var/www/html:ro,z \
  #                 --name nextcloud-caddy \
  #                 --pod nextcloud \
  #                 --restart on-failure \
  #                 docker.io/caddy:latest"
  export cmd=$(cat <<EOF
podman run --detach \
           --label "io.containers.autoupdate=registry" \
           --volume "${NEXTCLOUD_ROOT_DIR}"/caddy/caddy_data:/data:Z \
           --volume "${CADDYFILE}":/etc/caddy/Caddyfile:Z \
           --volume "${NEXTCLOUD_ROOT_DIR}"/html:/var/www/html:ro,z \
           --name nextcloud-caddy \
           --pod nextcloud \
           --restart on-failure \
           docker.io/caddy:latest
EOF
)           
run-cmd "${cmd}"               
}

function createSystemdService() {
  cd ~/.config/systemd/user/
  podman generate systemd --new --files --name nextcloud
  systemctl --user enable pod-nextcloud.service
  systemctl --user stop container-nextcloud-app.service
  systemctl --user restart container-nextcloud-app.service
  loginctl enable-linger $USER
}

# main
TEST_MODE="true"
while getopts "r" Option
do
    case $Option in
  		r    ) TEST_MODE="false";;
    esac
done
echo CONFIG_YAML=${CONFIG_YAML}
echo NEXTCLOUD_ROOT_DIR=${NEXTCLOUD_ROOT_DIR}
echo NEXTCLOUD_DATA_DIR=${NEXTCLOUD_DATA_DIR}
# createDirs
# createCaddyfile
createPod
# createMariaDBContainer
# createRedisContainer
# createNextcloudContainer
createCaddyContainer
# createSystemdService

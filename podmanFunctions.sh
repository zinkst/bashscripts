#!/bin/bash


function createSystemdService() {
cat << EOF > /etc/systemd/system/${SERVICE_NAME}.service
[Unit]
Description=${SERVICE_NAME} podman container

[Service]
Restart=always
ExecStart=/usr/bin/podman start -a ${SERVICE_NAME}
ExecStop=/usr/bin/podman stop ${SERVICE_NAME}

[Install]
WantedBy=multi-user.target
EOF

  systemctl enable ${SERVICE_NAME}.service
}

function createConfig() {
  mkdir -p ${DATA_DIR}  
}


function pullImage() {
  podman pull ${CONTAINER_IMAGE}
}  

function update() {
  pullImage
  systemctl stop ${SERVICE_NAME}.service
  podman stop ${SERVICE_NAME} 
  podman rm ${SERVICE_NAME}
  createPod
  systemctl start ${SERVICE_NAME}.service
}

function install() {
    createConfig
    pullImage
    createPod
    createSystemdService
}

function usage {
    echo "no argument specified usage:"
    echo "${0} -u # update"
    echo "${0} -i # install"
}

function main() {
  if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

  if [[ $1 == "" ]]; then
    usage;
    exit 1;
  else
      while getopts "ui" OPTNAME
      do
          case "${OPTNAME}" in
              "u")
              echo "Operation selected ist update"
              update
              ;;
              "i")
              echo "Operation selected ist install"
              install
              ;;
              "*")
              usage
              exit 1
              ;;
          esac
      done
  fi
}

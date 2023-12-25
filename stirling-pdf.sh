#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PODMAN_CONTAINER_DIR="/links/lokal/podman/"
CONTAINER_NAME="stirling-pdf"

mkdir -p "${PODMAN_CONTAINER_DIR}/${CONTAINER_NAME}/trainingData"
mkdir -p "${PODMAN_CONTAINER_DIR}/${CONTAINER_NAME}/extraConfigs"
mkdir -p "${PODMAN_CONTAINER_DIR}/${CONTAINER_NAME}/logs"

function start() {
  if [ -n "$(podman ps -f "name=${CONTAINER_NAME}" -f "status=running" -q )" ]; then
    echo "${CONTAINER_NAME} is already running!"
  else
    echo "starting  ${CONTAINER_NAME}"
    podman run -d \
    -p 8080:8080 \
    -v "${PODMAN_CONTAINER_DIR}/${CONTAINER_NAME}/trainingData":/usr/share/tesseract-ocr/5/tessdata \
    -v "${PODMAN_CONTAINER_DIR}/${CONTAINER_NAME}/extraConfigs":/configs \
    -v "${PODMAN_CONTAINER_DIR}/${CONTAINER_NAME}/logs":/logs \
    -e DOCKER_ENABLE_SECURITY=false \
    --name ${CONTAINER_NAME} \
    frooodle/s-pdf:latest
  fi
}

function stop() {
  podman stop ${CONTAINER_NAME}
  podman rm ${CONTAINER_NAME}
}

function usage() {
  echo "${0} -r to start  ${CONTAINER_NAME}"
  echo "${0} -s to stop  ${CONTAINER_NAME}"
}

# main
while getopts "rs" OPTNAME
do
  case "${OPTNAME}" in
    "s")
      echo "Option stop ${OPTNAME} is specified"
      stop
      exit 0
      ;;
    "r")
      echo "Option start ${OPTNAME} is specified"
      start
      sleep 10
      xdg-open http://localhost:8080 &
      exit 0
      ;;
  esac
  #echo "OPTIND is now $OPTIND"
done
usage
exit 1


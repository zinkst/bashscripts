#!/bin/sh
# Linux Start-Script fuer regulaeren Standalone-Betrieb.
# Jameica wird hierbei mit GUI gestartet.

function run() {
  cd ${TARGET_DIR}/${PROGRAM}-${VERSION}
  cmd="java -jar ${TARGET_DIR}/${PROGRAM}-${VERSION}/${PROGRAM}-linux64.jar"
  echo $cmd
  eval $cmd
}

function update() {
  if [ ! -d ${TARGET_DIR}/${PROGRAM}-${VERSION} ]; then
    echo "updating ${PROGRAM}"
    if [ ! -f ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux64.zip ]; then
       wget -O ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux64.zip https://www.willuhn.de/products/jameica/releases/current/jameica/jameica-linux64.zip
    fi  
    unzip ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux64.zip -d ${TARGET_DIR}/${PROGRAM}-${VERSION}
    cd ${TARGET_DIR}/${PROGRAM}-${VERSION}
    shopt -s dotglob
    mv jameica/* .
    rmdir jameica
  fi
}

# main
export TARGET_DIR="/home/share"
export VERSION=2.10.4
export PROGRAM=jameica

#main
update
run

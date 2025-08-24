#!/bin/bash

function run() {
  cmd="java -jar ${TARGET_DIR}/${PROGRAM}-${VERSION}-linux/lib/${PROGRAM}-basic-${VERSION}.jar"
  cmd=${TARGET_DIR}/${PROGRAM}-basic-${VERSION}-linux-x64/bin/${PROGRAM}.sh
  echo $cmd
  eval $cmd
}

function update() {
  if [ ! -d ${TARGET_DIR}/${PROGRAM}-basic-${VERSION}-linux-x64 ]; then
    echo "updating ${PROGRAM}"
    if [ ! -f ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux.tar.gz ]; then
      wget -O ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux.tar.gz https://github.com/torakiki/pdfsam/releases/download/v${VERSION}/pdfsam-basic-${VERSION}-linux-x64.tar.gz
    fi  
    tar -xzf ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux.tar.gz -C ${TARGET_DIR}
  fi
}

# main
export TARGET_DIR="/home/share"
export VERSION=5.3.1
export PROGRAM=pdfsam

#main
update
run
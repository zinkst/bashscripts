#!/bin/bash

function run() {
  cmd="java -jar ${TARGET_DIR}/${PROGRAM}-${VERSION}-linux/${PROGRAM}-basic-${VERSION}.jar"
  echo $cmd
  eval $cmd
}

function update() {
  if [ ! -d ${TARGET_DIR}/${PROGRAM}-${VERSION}-linux ]; then
    echo "updating ${PROGRAM}"
    if [ ! -f ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux.tar.gz ]; then
      wget -O ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux.tar.gz https://github.com/torakiki/pdfsam/releases/download/v${VERSION}/pdfsam-${VERSION}-linux.tar.gz
    fi  
    tar -xzf ${HOME}/Downloads/${PROGRAM}-${VERSION}-linux.tar.gz -C ${TARGET_DIR}
  fi
}

# main
export TARGET_DIR="/home/share"
export VERSION=4.3.4
export PROGRAM=pdfsam

#main
update
run
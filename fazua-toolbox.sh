#!/bin/sh

function run() {
  ${PROGRAM}
}

function update() {
  if [ ! -d ${TARGET_DIR}/${PROGRAM}-${VERSION} ]; then
    mkdir -p ${TARGET_DIR}/${PROGRAM}-${VERSION}
    echo "updating ${PROGRAM}"
    if [ ! -f ${HOME}/Downloads/${PROGRAM}-${VERSION}.tar.gz ]; then
       wget -O "${HOME}/Downloads/${PROGRAM}-${VERSION}.tar.gz" https://fazua.com/documents/1523/FAZUA_Toolbox_basic-linux-x86_64-${VERSION}.tar.gz
    fi  
    tar -xzf ${HOME}/Downloads/${PROGRAM}-${VERSION}.tar.gz -C ${TARGET_DIR}/${PROGRAM}-${VERSION}
    cd ${TARGET_DIR}/${PROGRAM}-${VERSION}
    rm ${TARGET_DIR}/${PROGRAM}
    ln -sf ${TARGET_DIR}/${PROGRAM}-${VERSION}/FAZUA_Toolbox_basic-linux-x86_64-${VERSION} ${TARGET_DIR}/${PROGRAM}
  fi
}

# main
export TARGET_DIR="/home/share"
export VERSION=2.21
export PROGRAM=fazua-toolbox

#main
update
run

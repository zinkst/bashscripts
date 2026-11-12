#!/bin/sh

function run() {
  ${TARGET_DIR}/${PROGRAM}
}

function update() {
  if [ ! -d ${TARGET_DIR}/${PROGRAM}-${VERSION} ]; then
    mkdir -p ${TARGET_DIR}/${PROGRAM}-${VERSION}
    echo "updating ${PROGRAM}"
    if [ ! -f ${HOME}/Downloads/${PROGRAM}-${VERSION}.tar.gz ]; then
       # https://fazua.com/documents/1662/FAZUA_Toolbox_basic-linux-x86_64-2.28.tar.gz
       # https://fazua.com/documents/1675/FAZUA_Toolbox_basic-linux-x86_64-2.29.tar.gz
       wget -O "${HOME}/Downloads/${PROGRAM}-${VERSION}.tar.gz" https://fazua.com/documents/1675/FAZUA_Toolbox_basic-linux-x86_64-${VERSION}.tar.gz
    fi  
    tar -xzf ${HOME}/Downloads/${PROGRAM}-${VERSION}.tar.gz -C ${TARGET_DIR}/${PROGRAM}-${VERSION}
    cd ${TARGET_DIR}/${PROGRAM}-${VERSION}
    rm ${TARGET_DIR}/${PROGRAM}
    ln -sf ${TARGET_DIR}/${PROGRAM}-${VERSION}/FAZUA_Toolbox_basic-linux-x86_64-${VERSION} ${TARGET_DIR}/${PROGRAM}
  fi
}

# main
export TARGET_DIR="/home/share"
export VERSION=2.29
export PROGRAM=fazua-toolbox

#main
update
run

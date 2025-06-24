#!/bin/sh

function installLegalyamlTools() {
  set -x
  pushd ${HOME}/go/src
  if [[ ! $(command -v osld-lint) ]]; then 
    go install github.ibm.com/oss-license-declaration/lint@latest
    ln -sf ${HOME}/go/bin/lint ${HOME}/go/bin/osld-lint
  fi  
  if [[ ! $(command -v osld-generator-go) ]]; then 
    go install github.ibm.com/oss-license-declaration/generator-go@latest
    cmd="ln -sf ${HOME}/go/bin/generator-go ${HOME}/go/bin/osld-generator-go"
    echo $cmd
    eval $cmd
  fi
  popd
}

function installGinkgo() {
	pushd ${HOME}/go
	GINKGO2_VERSION="2.23.0"
  go install github.com/onsi/ginkgo/v2/ginkgo@v${GINKGO2_VERSION}
  mkdir -p ${TARGET_DIR}/ginkgo-versions/
	mv ~/go/bin/ginkgo ${TARGET_DIR}/ginkgo-versions/ginkgo-${GINKGO2_VERSION}
	ln -sf ${TARGET_DIR}/ginkgo-versions/ginkgo-${GINKGO2_VERSION} ${TARGET_DIR}/ginkgo2
	# go install github.com/onsi/ginkgo/ginkgo@v1.16.5
	# mv ~/go/bin/ginkgo ${TARGET_DIR}/ginkgo-versions/ginkgo-v1.16.5
	# ln -sf ${TARGET_DIR}/ginkgo-versions/ginkgo-v1.16.5 ${TARGET_DIR}/ginkgo1
  popd 
}

function installGolangFromTGZ(){
  GO_VERSION="1.23.2"
  if [ ! -f ${HOME}/Downloads/go${GO_VERSION}.linux-amd64.tar.gz ]; then 
    wget -O ${HOME}/Downloads/go${GO_VERSION}.linux-amd64.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
  fi
  rm -rf ${TARGET_DIR}/go-${GO_VERSION}
  mkdir -p ${TARGET_DIR}/go-${GO_VERSION}
  tar -C ${TARGET_DIR}/go-${GO_VERSION} -xzf ${HOME}/Downloads/go${GO_VERSION}.linux-amd64.tar.gz
  mv ${TARGET_DIR}/go-${GO_VERSION}/go/* ${TARGET_DIR}/go-${GO_VERSION}
  rmdir ${TARGET_DIR}/go-${GO_VERSION}/go
  if [ -f ${TARGET_DIR}/go ]; then 
    rm ${TARGET_DIR}/go
  fi  
  ln -sf ${TARGET_DIR}/go-${GO_VERSION}/bin/go ${TARGET_DIR}/go
  if [ -f ${TARGET_DIR}/gofmt ]; then 
    rm ${TARGET_DIR}/gofmt
  fi  
  ln -sf ${TARGET_DIR}/go-${GO_VERSION}/bin/gofmt ${TARGET_DIR}/gofmt
}

function installDetectSecrets() {
  # see https://w3.ibm.com/w3publisher/detect-secrets/developer-tool
  pip install --upgrade "git+https://github.com/ibm/detect-secrets.git@master#egg=detect-secrets"
  pip show detect-secrets | grep Location
}

function installWebExRPM() {
  RPM_URL="https://binaries.webex.com/WebexDesktop-CentOS-Official-Package/Webex.rpm"
  RPM_DATE=$(date +'%Y%m%d')
  RPM_NAME="webex"
  if [ ! -f ${HOME}/Downloads/${RPM_DATE}-${RPM_NAME}.rpm ]; then 
    wget -O ${HOME}/Downloads/${RPM_DATE}-${RPM_NAME}.rpm ${RPM_URL}
  fi
  RPM_VERSION=$(rpm -q --info ${HOME}/Downloads/${RPM_DATE}-${RPM_NAME}.rpm 2> /dev/null | grep "Version" | cut  -d ":" -f 2 | xargs)
  if [ ! -f ${HOME}/Downloads/${RPM_NAME}-${RPM_VERSION}.rpm ]; then 
    cp ${HOME}/Downloads/${RPM_DATE}-${RPM_NAME}.rpm ${HOME}/Downloads/${RPM_NAME}-${RPM_VERSION}.rpm
  fi  
  cmd="sudo dnf install ${HOME}/Downloads/${RPM_NAME}-${RPM_VERSION}.rpm"
  echo $cmd
  eval ${cmd}
}

# main
export TARGET_DIR=${HOME}/.local/bin
#hashMap
installGinkgo
#installDetectSecrets
#installLegalyamlTools
#installGolangFromTGZ
#installWebExRPM

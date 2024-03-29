#!/bin/sh

# function hashMap() 
# {
#   commands=("goml" "spruce" "kubectl" "fly")
#   declare -A goml
#   goml["version"]="v0.8.0"
#   goml["URL"]="https://github.com/herrjulz/goml/releases/download/${goml["version"]}/goml-linux-amd64"

#   declare -A fly
#   fly["version"]="v7.6.0"
#   fly["URL"]="https://concourse.cf.w3.cloud.ibm.com/api/v1/cli?arch=amd64&platform=linux"

#   echo ${goml["version"]} 
#   echo ${goml["URL"]} 
# }


function installBinary(){
  ind=${1}
 	mkdir -p ${TARGET_DIR}/${COMMAND[ind]}-versions/
	wget -O ${TARGET_DIR}/${COMMAND[ind]}-versions/${COMMAND[ind]}-${COMMAND_VERSION[ind]} ${DOWNLOAD_URL[ind]} 
  ls -l ${TARGET_DIR}/${COMMAND[ind]}-versions/
  switchCommand.sh ${COMMAND[ind]} ${COMMAND_VERSION[ind]}
}

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

function installBinaryFromTGZ(){
  ind=${1}
 	mkdir -p ${TARGET_DIR}/${COMMAND[ind]}-versions/temp-extract
	if [ ! -f "${TARGET_DIR}/${COMMAND[ind]}-versions/${COMMAND[ind]}-${COMMAND_VERSION[ind]}.tar.gz" ]; then
    wget -O ${TARGET_DIR}/${COMMAND[ind]}-versions/${COMMAND[ind]}-${COMMAND_VERSION[ind]}.tar.gz ${DOWNLOAD_URL[ind]} 
  else
    echo "${TARGET_DIR}/${COMMAND[ind]}-versions/${COMMAND[ind]}-${COMMAND_VERSION[ind]}.tar.gz" already downloaded
  fi
  cd ${TARGET_DIR}/${COMMAND[ind]}-versions/
  tar -xzf ${TARGET_DIR}/${COMMAND[ind]}-versions/${COMMAND[ind]}-${COMMAND_VERSION[ind]}.tar.gz -C temp-extract
	cp temp-extract/${BINARY_TARGET[ind]} ${TARGET_DIR}/${COMMAND[ind]}-versions/${COMMAND[ind]}-${COMMAND_VERSION[ind]}
  ls -l ${TARGET_DIR}/${COMMAND[ind]}-versions/
  switchCommand.sh ${COMMAND[ind]} ${COMMAND_VERSION[ind]}
  rm -rf temp-extract
  rm ${TARGET_DIR}/${COMMAND[ind]}-versions/${COMMAND[ind]}-${COMMAND_VERSION[ind]}.tar.gz
}


function installDevToolsfromBinaryTGZ(){
  COMMAND_VERSION[0]="1.51.1"
  COMMAND[0]="golangci-lint"
  DOWNLOAD_URL[0]="https://github.com/golangci/golangci-lint/releases/download/v${COMMAND_VERSION[0]}/golangci-lint-${COMMAND_VERSION[0]}-linux-amd64.tar.gz"
  BINARY_TARGET[0]="golangci-lint-${COMMAND_VERSION[0]}-linux-amd64/golangci-lint"

  COMMAND[1]="k9s"
  COMMAND_VERSION[1]="0.30.8"
  DOWNLOAD_URL[1]="https://github.com/derailed/k9s/releases/download/v${COMMAND_VERSION[1]}/k9s_Linux_amd64.tar.gz"
  BINARY_TARGET[1]="k9s"
  
  COMMAND[2]="dyff"
  COMMAND_VERSION[2]="1.5.6"
  BINARY_TARGET[2]="dyff"
  DOWNLOAD_URL[2]="https://github.com/homeport/dyff/releases/download/v${COMMAND_VERSION[2]}/dyff_${COMMAND_VERSION[2]}_linux_amd64.tar.gz"
  
  COMMAND[3]="fly"
  COMMAND_VERSION[3]="7.10.0"
  DOWNLOAD_URL[3]="https://github.com/concourse/concourse/releases/download/v${COMMAND_VERSION[3]}/fly-${COMMAND_VERSION[3]}-linux-amd64.tgz"
  BINARY_TARGET[3]="fly"

  COMMAND[4]="helm"
  COMMAND_VERSION[4]="3.10.3"
  DOWNLOAD_URL[4]="https://get.helm.sh/helm-v${COMMAND_VERSION[4]}-linux-amd64.tar.gz"
  BINARY_TARGET[4]="linux-amd64/helm"

  # shift-report download URL doesn't work due to redirect
  COMMAND[5]="shift-report"
  COMMAND_VERSION[5]="0.5.0"
  DOWNLOAD_URL[5]="https://github.ibm.com/ENCALADA/shift-report/releases/download/v${COMMAND_VERSION[5]}/shift-report_${COMMAND_VERSION[5]}_Linux_x86_64.tar.gz"
  BINARY_TARGET[5]="shift-report"
  
  COMMAND[6]="havener"
  COMMAND_VERSION[6]="2.0.8"
  DOWNLOAD_URL[6]="https://github.com/homeport/havener/releases/download/v${COMMAND_VERSION[6]}/havener_${COMMAND_VERSION[6]}_linux_amd64.tar.gz"
  BINARY_TARGET[6]="havener"
  
  COMMAND[7]="retry"
  COMMAND_VERSION[7]="0.1.3"
  DOWNLOAD_URL[7]="https://github.com/homeport/retry/releases/download/v${COMMAND_VERSION[7]}/retry_${COMMAND_VERSION[7]}_linux_amd64.tar.gz"
  BINARY_TARGET[7]="retry"
  
  COMMAND[8]="stern"
  COMMAND_VERSION[8]="1.25.0"
  DOWNLOAD_URL[8]="https://github.com/stern/stern/releases/download/v${COMMAND_VERSION[8]}/stern_${COMMAND_VERSION[8]}_linux_amd64.tar.gz"
  BINARY_TARGET[8]="stern"
  
  COMMAND[9]="kubectl-neat"
  COMMAND_VERSION[9]="2.0.3"
  DOWNLOAD_URL[9]="https://github.com/itaysk/kubectl-neat/releases/download/v${COMMAND_VERSION[9]}/kubectl-neat_linux_amd64.tar.gz"
  BINARY_TARGET[9]="kubectl-neat"

  COMMAND[10]="ko"
  COMMAND_VERSION[10]="0.14.1"
  DOWNLOAD_URL[10]="https://github.com/ko-build/ko/releases/download/v${COMMAND_VERSION[10]}/ko_Linux_x86_64.tar.gz"
  BINARY_TARGET[10]="ko"

  COMMAND[11]="yft"
  COMMAND_VERSION[11]="1.0.6"
  DOWNLOAD_URL[11]="https://github.com/homeport/yft/releases/download/v${COMMAND_VERSION[11]}/yft_${COMMAND_VERSION[11]}_linux_amd64.tar.gz"
  BINARY_TARGET[11]="yft"

  COMMAND[12]="pack"
  COMMAND_VERSION[12]="0.32.1"
  DOWNLOAD_URL[12]="https://github.com/buildpacks/pack/releases/download/v${COMMAND_VERSION[12]}/pack-v${COMMAND_VERSION[12]}-linux.tgz"
  BINARY_TARGET[12]="pack"

  COMMAND[13]="pspblueprint"
  COMMAND_VERSION[13]="0.2.0"
  DOWNLOAD_URL[13]="https://github.ibm.com/ENCALADA/pspblueprint/releases/download/v${COMMAND_VERSION[13]}/pspblueprint_${COMMAND_VERSION[13]}_Linux_x86_64.tar.gz"
  BINARY_TARGET[13]="pspblueprint"
  
  COMMAND[14]="tsh"
  COMMAND_VERSION[14]="13.3.8"
  DOWNLOAD_URL[14]="https://cdn.teleport.dev/teleport-v${COMMAND_VERSION[14]}-linux-amd64-bin.tar.gz"
  BINARY_TARGET[14]="teleport/tsh"
  
  COMMAND[15]="teleport"
  COMMAND_VERSION[15]="13.3.8"
  DOWNLOAD_URL[15]="https://cdn.teleport.dev/teleport-v${COMMAND_VERSION[15]}-linux-amd64-bin.tar.gz"
  BINARY_TARGET[15]="teleport/teleport"
  
  COMMAND[16]="tctl"
  COMMAND_VERSION[16]="13.3.8"
  DOWNLOAD_URL[16]="https://cdn.teleport.dev/teleport-v${COMMAND_VERSION[16]}-linux-amd64-bin.tar.gz"
  BINARY_TARGET[16]="teleport/tctl"
  
  COMMAND[17]="gosec"
  COMMAND_VERSION[17]="2.18.2"
  DOWNLOAD_URL[17]="https://github.com/securego/gosec/releases/download/v${COMMAND_VERSION[17]}/gosec_${COMMAND_VERSION[17]}_linux_amd64.tar.gz"
  BINARY_TARGET[17]="gosec"
  
  https://github.com/securego/gosec/releases/download/v2.18.2/gosec_2.18.2_linux_amd64.tar.gz

  index=(0 1 2 3 4 5 6 7 8 9 10 11 12 13)
  index=(1) 
  for i in "${index[@]}"
  do
    # do whatever on "$i" here
    installBinaryFromTGZ ${i}
  done


}

function installDevToolsfromBinary(){

  COMMAND_VERSION[0]="v0.8.0"
  COMMAND[0]="goml"
  DOWNLOAD_URL[0]="https://github.com/herrjulz/goml/releases/download/${COMMAND_VERSION[0]}/goml-linux-amd64"

  COMMAND[1]="kubebuilder"
  COMMAND_VERSION[1]="v3.7.0"
  DOWNLOAD_URL[1]="https://github.com/kubernetes-sigs/kubebuilder/releases/download/${COMMAND_VERSION[8]}/kubebuilder_linux_amd64"
  
  COMMAND[2]="kubectl"
  COMMAND_VERSION[2]="v1.27.9"
  DOWNLOAD_URL[2]="https://storage.googleapis.com/kubernetes-release/release/${COMMAND_VERSION[2]}/bin/linux/amd64/kubectl"

  COMMAND[3]="spruce"
  COMMAND_VERSION[3]="v1.29.0"
  DOWNLOAD_URL[3]="https://github.com/geofffranks/spruce/releases/download/${COMMAND_VERSION[3]}/spruce-linux-amd64"

  COMMAND[4]="yq"
  COMMAND_VERSION[4]="v4.28.1"
  DOWNLOAD_URL[4]="https://github.com/mikefarah/yq/releases/download/${COMMAND_VERSION[4]}/yq_linux_amd64"

  COMMAND[5]="kubectx"
  COMMAND_VERSION[5]="master"
  DOWNLOAD_URL[5]="https://github.com/ahmetb/kubectx/raw/${COMMAND_VERSION[5]}/kubectx"

  COMMAND[6]="kubens"
  COMMAND_VERSION[6]="master"
  DOWNLOAD_URL[6]="https://github.com/ahmetb/kubectx/raw/${COMMAND_VERSION[6]}/kubens"

  COMMAND[7]="kind"
  COMMAND_VERSION[7]="v0.20.0"
  DOWNLOAD_URL[7]="https://github.com/kubernetes-sigs/kind/releases/download/${COMMAND_VERSION[7]}/kind-linux-amd64"

  COMMAND[8]="aviator"
  COMMAND_VERSION[8]="v1.9.0"
  DOWNLOAD_URL[8]="https://github.com/herrjulz/aviator/releases/download/${COMMAND_VERSION[8]}/aviator-linux-amd64"

  COMMAND[9]="calicoctl"
  COMMAND_VERSION[9]="3.24.5"
  DOWNLOAD_URL[9]="https://github.com/projectcalico/calico/releases/download/v${COMMAND_VERSION[9]}/calicoctl-linux-amd64"

  COMMAND[10]="kn"
  COMMAND_VERSION[10]="1.9.2"
  DOWNLOAD_URL[10]="https://github.com/knative/client/releases/download/knative-v${COMMAND_VERSION[10]}/kn-linux-amd64"

  COMMAND[11]="spotdl"
  COMMAND_VERSION[11]="4.2.0"
  DOWNLOAD_URL[11]="https://github.com/spotDL/spotify-downloader/releases/download/v${COMMAND_VERSION[11]}/spotdl-${COMMAND_VERSION[11]}-linux"

  COMMAND[12]="hey"
  COMMAND_VERSION[12]="0.1.4"
  DOWNLOAD_URL[12]="https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64"

  index=(0 1 2 3 4 5 6 7)
  index=(2) 
  for i in "${index[@]}"
  do
    # do whatever on "$i" here
    installBinary ${i}
  done
}

function installGinkgo() {
	pushd ${HOME}/go
	GINKGO2_VERSION="2.12.1"
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
  GO_VERSION="1.20.6"
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
#installGinkgo
#installDetectSecrets
installDevToolsfromBinary
#installLegalyamlTools
#installDevToolsfromBinaryTGZ
#installGolangFromTGZ
#installWebExRPM

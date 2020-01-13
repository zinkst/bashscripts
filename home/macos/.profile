#!/bin/bash
# Get the aliases and functions
if [ -f ~/.functions.sh ]; then
	source ~/.functions.sh
fi

# User specific environment and startup programs

#export PS1="\u@\h \W\$ "
#export TERM=xterm-256color
#export GEM_HOME="${HOME}/.gem"
export GOPATH="${HOME}/Documents/workdata/BlueMix/work/go"
#export GOROOT="/usr/local/opt/go/libexec"
export BM="${HOME}/BlueMix"
export GHE="${BM}/gits/GHE/"
export BEDROCK_WORKSPACE="${GHE}bedrock/"
export BWS=${BEDROCK_WORKSPACE}
export ELR=${BWS}elk-adapter-release
export EVR=${ELR}/src/github.ibm.com/bedrock/event-forwarder
export EVA=${ELR}/src/github.ibm.com/bedrock/event-forwarder-acceptance-tests
export EKR=${ELR}/src/loggregator-elk
export EKA=${ELR}/src/github.ibm.com/bedrock/elkadapter-acceptance-tests
export MY_CRED_FILE="${HOME}/BlueMix/gits/GHE/Stefan-Zink/SZUtils/credentials.yml"
export SSO_P=$(yq read ${MY_CRED_FILE} SSO_PWD)
export W3ID_PWD=$(yq read ${MY_CRED_FILE} W3_PWD)
export IBMID_PWD=$(yq read ${MY_CRED_FILE} IBMID_PWD)

alias ic="ibmcloud"
alias kc="kubectl"
alias git='LANG=en_US.UTF-8 git'
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagaced
source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh
export PATH=$HOME/bin:$HOME/BlueMix/bin:$GOPATH/bin:$PATH:/usr/local/sbin
export GIT_DUET_GLOBAL=true
export GIT_DUET_ROTATE_AUTHOR=1
#export LC_ALL=en_US.UTF-8
#export LANG=en_US.UTF-8


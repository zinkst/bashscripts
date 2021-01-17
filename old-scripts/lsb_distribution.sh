#!/bin/bash
DISTRIBUTOR=`lsb_release -i | awk ' BEGIN { FS=":" }; {print $2}'`
echo ${DISTRIBUTOR}
RELEASE=`lsb_release -r | awk ' BEGIN { FS=":" }; {print $2}'`
echo ${RELEASE}
ARCHITECTURE=`uname -m`
echo ${ARCHITECTURE}
DISTRIBUTION=${DISTRIBUTOR}_${RELEASE}_${ARCHITECTURE}
DISTRIBUTION=`echo ${DISTRIBUTION} | sed -e "s/ //g"`
echo ${DISTRIBUTION}

. /links/bashscripts/bkp_functions.sh

java_env "open"
java_env
CORRECTHOST="zinkstp"
checkCorrectHost

#!/bin/bash

CORRECTHOST="zink-pc3"
index="1"

# SSH_HOST="zinksrv"
# SSH_TGT_ROOT="root@${SSH_HOST}:/local/data/zink-pc3/"
# USE_SSH=false

Directories[1]="local/data/${CORRECTHOST}"
TargetDir[1]="data/${CORRECTHOST}/data"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"

. /links/bin/lib/bkp_functions.sh

# main routine
processRsyncBackup() $@

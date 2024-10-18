#!/bin/bash

CORRECTHOST="zink-pc3"
export TGT_ROOT=${TGT_ROOT:-"/remote/zinksrv/nfs4/"}
 
index="1"

Directories[1]="local/data/${CORRECTHOST}"
TargetDir[1]="data/${CORRECTHOST}/data"
MountTestFile[1]="${TGT_ROOT}data/doNotDelete"

. /links/bin/lib/bkp_functions.sh

# main routine
processRsyncBackup $@

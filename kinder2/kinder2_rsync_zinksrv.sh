#!/bin/bash

CORRECTHOST="kinder2"
TGT_ROOT="/remote/zinksrv/nfs4/"
index="1 2"

Directories[1]="local/data/kinder2"
TargetDir[1]="data/kinder2/data"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
Directories[2]="local/backup/kinder2"
TargetDir[2]="data/kinder2/backup/kinder2"
MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"


. /links/bin/lib/bkp_functions.sh

# main routine
processRsyncBackup $@

#!/bin/bash

CORRECTHOST=$(hostname -s)
TGT_ROOT="/remote/zinksrv/nfs4/"
index="1"


Directories[1]="local/data/zink-pc4"
TargetDir[1]="data/zink-pc4/data/zink-pc4"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
# Directories[2]="local/data_hdd/zink-ry4650g"
# TargetDir[2]="data/zink-ry4650g/data_hdd/zink-ry4650g"
# MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"

source /links/bin/lib/bkp_functions.sh

# main routine
processRsyncBackup $@
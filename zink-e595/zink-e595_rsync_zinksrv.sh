#!/bin/bash

TGT_ROOT="/remote/zinksrv/nfs4/"
CORRECTHOST="zink-e595"
MEDIA_SYNC_YEAR=2024
index="1 2 3 4 5 6 7 8 9 10"


Directories[1]="local/data/${CORRECTHOST}/lokal"
TargetDir[1]="data/${CORRECTHOST}/data/lokal"
MountTestFile[1]=${TGT_ROOT}"data/doNotDelete"
Directories[2]="local/ssd-data/Photos/unsorted"
TargetDir[2]="data/${CORRECTHOST}/ssd-data/Photos/unsorted"
MountTestFile[2]=${TGT_ROOT}"data/doNotDelete"
Directories[3]="local/data/${CORRECTHOST}/homes"
TargetDir[3]="data/${CORRECTHOST}/data/homes"
MountTestFile[3]=${TGT_ROOT}"data/doNotDelete"
Directories[4]="local/data/${CORRECTHOST}/Musik"
TargetDir[4]="data/zinksrv/Musik"
MountTestFile[4]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[4]=false
Directories[5]="local/data/${CORRECTHOST}/FamilienVideos/Familie-Zink-Videos/${MEDIA_SYNC_YEAR}"
TargetDir[5]="data/zinksrv/FamilienVideos/Familie-Zink-Videos/${MEDIA_SYNC_YEAR}"
MountTestFile[5]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[5]=true
Directories[6]="local/ssd-data/Photos/${MEDIA_SYNC_YEAR}"
TargetDir[6]="data/zinksrv/Photos/Sammlung/${MEDIA_SYNC_YEAR}"
MountTestFile[6]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[6]=true
Directories[7]="local/data/${CORRECTHOST}/FamilienVideos/Videos Familie Zink/${MEDIA_SYNC_YEAR}"
TargetDir[7]="data/Not4Backup/shared/Videos Familie Zink/${MEDIA_SYNC_YEAR}"
MountTestFile[7]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[7]=true
Directories[8]="local/ssd-data/FamilienVideos/unsorted"
TargetDir[8]="data/${CORRECTHOST}/ssd-data/FamilienVideos/unsorted"
MountTestFile[8]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[8]=true
Directories[9]="local/data/${CORRECTHOST}/Photos/Favoriten"
TargetDir[9]="data/zinksrv/Photos/Favoriten"
MountTestFile[9]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[9]=true
Directories[10]="local/data/${CORRECTHOST}/FamilienVideos/Favoriten-Familie-Zink-Videos/${MEDIA_SYNC_YEAR}"
TargetDir[10]="data/zinksrv/FamilienVideos/Favoriten-Familie-Zink-Videos/${MEDIA_SYNC_YEAR}"
MountTestFile[10]=${TGT_ROOT}"data/doNotDelete"
AllowDelete[10]=true


. /links/bin/lib/bkp_functions.sh

# main routine
processRsyncBackup $@

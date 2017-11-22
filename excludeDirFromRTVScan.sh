#!/bin/bash
# relevant commands
#/opt/Symantec/symantec_antivirus/symcfg add -k 'VirusProtect6\Storages\FileSystem\RealTimeScan\NoScanDir\' -v /media/win/d/persdata/mozillaprofiles/thunderbird -t reg_dword -d 1
#
#./symcfg list -k "VirusProtect6\Storages\FileSystem\RealTimeScan\NoScanDir"
KEYNAME="'VirusProtect6\Storages\FileSystem\RealTimeScan\NoScanDir'"
SYMCFG="/opt/Symantec/symantec_antivirus/symcfg"
#$COMMAND add -k $KEYNAME -v $1 -t reg_dword -d 1
CMD="${SYMCFG} list -k $KEYNAME" 
CMD="${SYMCFG} add -k $KEYNAME -v $1 -t reg_dword -d 1"
echo ${CMD}
`${CMD}`

#/opt/ibm/InstallationManager
#/opt/ibm/ISAandESA
#/opt/ibm/sametime
#/opt/ibm/SDP70
#/opt/ibm/SDP70Shared
#/opt/ibm/lotus/notes/framework
#/opt/ibm/lotus/Sametime
#/opt/ibm/lotus/symphony

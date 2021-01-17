#!/bin/sh
LOGFILENAME="${HOME}/firewall_sh.log"
echo $0 $@ | tee -a  ${LOGFILENAME}
#cmdparms=("$@")
#for parm in ${cmdparms}
#do
#  echo $parm | tee -a  ${LOGFILENAME}
#done

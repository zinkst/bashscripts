#!/bin/bash
export WRKDIR=${HOME}/.bsobb
if [ ! -d ${WRKDIR} ]
then
  mkdir ${WRKDIR}
fi
cd ${WRKDIR}
curl -L -b cookies.txt -c cookies.txt --insecure --data-urlencode "username=zinks@de.ibm.com" --data-urlencode "password=i1Bluemx" -d "realm=ALTERNATE_IBM_Intranet_Auth&btnSubmit=Sign+In" https://bso.boeblingen.de.ibm.com/dana-na/auth/url_2/login.cgi 

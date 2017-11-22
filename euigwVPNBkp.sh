#/bin/bash

# variables
BACKUPDIR=/backup
REMOTEBACKUPDIR=/backup
SERVERNAME=$1
SERVERIP=$2

if [ -z $1 ]
then
    echo -n "usage euiVPNBkp.sh <servername> <serverip>"
    echo -n "e.g.:  "
    echo -n "euiVPNBkp.sh euigw1 ${SERVERIP}"
fi    

# test if euigw1 is reachable
ping -q -c 5 ${SERVERIP}
if [ $? -ne 0 ]
then
  exit
fi

# remove oldest version and move other versions one step older
rm ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg05.tgz
mv ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg04.tgz ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg05.tgz
mv ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg03.tgz ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg04.tgz
mv ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg02.tgz ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg03.tgz
mv ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg01.tgz ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg02.tgz

# create tar of old backup
tar -czf ${REMOTEBACKUPDIR}/${SERVERNAME}_vpncfg01.tgz ${BACKUPDIR}/${SERVERNAME}/*

# create new backup
scp -pr root@${SERVERIP}:/etc/ssl ${BACKUPDIR}/${SERVERNAME}/etc/ssl
scp -pr root@${SERVERIP}:/etc/ipsec.d ${BACKUPDIR}/${SERVERNAME}/etc/ipsec.d
scp -p root@${SERVERIP}:/etc/ipsec.conf ${BACKUPDIR}/${SERVERNAME}/etc/
scp -r root@${SERVERIP}:/etc/x509cert.der ${BACKUPDIR}/${SERVERNAME}/etc/

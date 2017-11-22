tag=$(date +'%d')
monat=$(date +'%m')
jahr=$(date +'%y')
if [ -f /etc/fedora-release ]
then
	HOSTNAME=`hostname`
	#CORRECTHOST=${CORRECTHOST}.boeblingen.de.ibm.com
else
	HOSTNAME=`hostname -s`
fi

echo "HOSTNAME = ${HOSTNAME}"
if [ ${HOSTNAME} = "marion-laptop" ] 
then
  TARGETPATH="/links/madata/sysbkp/"
  TARGETFILENAME=${TARGETPATH}"${jahr}${monat}${tag}_marion-laptop_vista_ntfsclone.gz"
  SOURCEDISK="/dev/sda1"
elif [ ${HOSTNAME} = "zinkstp" ] || [ ${HOSTNAME} = "zinkstp.boeblingen.de.ibm.com" ] || [ ${HOSTNAME} = "stefan.zink.sulz.de" ] || [ ${HOSTNAME} = "stefan" ] 
then 
  TARGETPATH="/links/sysbkp/"
  TARGETFILENAME=${TARGETPATH}"${jahr}${monat}${tag}_zinkstp_xpc4eb_ntfsclone.gz"
  SOURCEDISK="/dev/sda1"
elif [ ${HOSTNAME} = "zinksrv" ] || [ ${HOSTNAME} = "zinksrv.zink.sulz.de" ] 
then 
  TARGETPATH="/links/sysbkp/zinksrv/"
  TARGETFILENAME=${TARGETPATH}"${jahr}${monat}${tag}_zinksrv_sda4_w81pr0_ntfsclone.gz"
  SOURCEDISK="/dev/sda4"
fi;
echo "TARGETFILENAME = " ${TARGETFILENAME}
if [ -z ${TARGETFILENAME} ]
then
  echo " host ${HOSTNAME} not known, not doing backup"
else
  echo "starting backup on $(date +%H:%M:%S)"
  echo "starting commmand:"
  echo "ntfsclone --save-image --output - ${SOURCEDISK} | gzip -c > ${TARGETFILENAME}"
  ntfsclone --save-image --output - ${SOURCEDISK} | pigz -c > ${TARGETFILENAME}
  echo "finished backup on $(date +%H:%M:%S)"
  echo "restore with \ngunzip -c ${TARGETFILENAME} | ntfsclone -r --overwrite ${SOURCEDISK} -"
fi





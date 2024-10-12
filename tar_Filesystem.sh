#!/bin/bash
. /links/bin/lib/bkp_functions.sh

tag=$(date +'%d')
monat=$(date +'%m')
jahr=$(date +'%y')



determineDistribution

determineSystemByHostname


usage ()
{
  echo "call ${0} [-f <FILESYSTEMMOUNTPOINT> ]  "
  echo "samples are:"
  echo "FILESYSTEMMOUNTPOINT=/"
  exit 0; 

}

#######################################
# main starts here
# intialize Parameters (may be overwritten with input parameter)
FILESYSTEMMOUNTPOINT="/"
while getopts ":f:h" OPTNAME
do
    case "${OPTNAME}" in
      "h")
	echo "Option ${OPTNAME} is specified"
	usage
	exit 0; 
	;;
      "f")
	echo "Option ${OPTNAME} is specified"
	FILESYSTEMMOUNTPOINT=${OPTARG} 
	;;
	*)
      # Should not occur
	echo "Unknown error while processing options"
	;;
    esac
    #echo "OPTIND is now $OPTIND"
done



TARGETPATH="/links/sysbkp"
if [ ${SYSTEM} = "tpibm" ] 
then 
  TARGETPATH="/links/sysbkp"
  if [ ! -f ${TARGETPATH}/doNotDelete ]
	then
		TARGETPATH="/local/data/ssd_backup/sysbkp"
  fi 	
fi

if [ ${FILESYSTEMMOUNTPOINT} = "/" ]
then
	TARGETFILENAME=${TARGETPATH}/${SYSTEM}_${DISTRIBUTION}_${jahr}${monat}${tag}.tgz
else
	FILESYTEM_FILENAME=${FILESYSTEMMOUNTPOINT//'/'/_} #replace / with _ 
	TARGETFILENAME=${TARGETPATH}/${SYSTEM}-${FILESYTEM_FILENAME}-${jahr}${monat}${tag}.tgz
fi    

echo "DISTRIBUTION = " ${DISTRIBUTION}
echo "TARGETFILENAME = " ${TARGETFILENAME}

if [ -z ${SYSTEM} ]
then
  echo " host ${HOSTNAME} not known, not doing backup"
else
  echo "starting backup on $(date +%H:%M:%S)"
  CMD="tar --selinux --acls --xattrs -cpf ${TARGETFILENAME} --directory ${FILESYSTEMMOUNTPOINT} --use-compress-program=pigz --one-file-system --numeric-owner --exclude=proc/* --exclude=mnt/* --exclude=*/lost+found --exclude=tmp/* ."
  echo ${CMD}
  #`${CMD}`
  ($CMD)
  echo "finished backup on $(date +%H:%M:%S)"
fi


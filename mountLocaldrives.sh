vmdb_answer_SBINDIR="/usr/sbin"
# echo $vmdb_answer_SBINDIR/vmware-checkvm

# Are we running in a VM?
vmware_inVM() {
  "$vmdb_answer_SBINDIR"/vmware-checkvm >/dev/null 2>&1
}
LOG_ROOT=/var/log
LOGFILENAME=mountLocalDrives.log
echo "starting ${0} on $(date +'%y%m%d_%H%M%S') " | tee -a ${LOG_ROOT}/${LOGFILENAME}
    
checkFSMounted ()
{
  mount | grep ${1}
  RC=$?
  echo "RC = ${RC} from mount | grep ${1}" | tee -a ${LOG_ROOT}/${LOGFILENAME}
  if [ $RC -eq 0 ]
  then
	echo "${1} already mounted" | tee -a ${LOG_ROOT}/${LOGFILENAME}
	return 1
  else
    return 0
  fi
}

if [ -e /links/backup ]
then 
	rm -f /links/backup
fi


if vmware_inVM;
then
    echo "running in VM" | tee -a ${LOG_ROOT}/${LOGFILENAME}
	mount //vmhost/data /remote/vmhost/data -t cifs -o credentials=/etc/samba/zinks.cred 
else
    echo "running native" | tee -a ${LOG_ROOT}/${LOGFILENAME}
    checkFSMounted "/local/backup"
    RC=$?
    if [ ${RC} -eq 0 ]
    then
		if [ -e /dev/sdb1 ]
		then
			echo "Backup drive installed try mount without open luksContainer"	| tee -a ${LOG_ROOT}/${LOGFILENAME}
			mount /dev/backupvg/BACKUP	/local/backup
			RC=$?
			if [ ${RC} -ne 0 ]
			then
			    echo "Cryptocontainer /dev/sdb1 not yet opened opening with keyfile" | tee -a ${LOG_ROOT}/${LOGFILENAME}
			    cryptsetup --key-file /links/persdata/Stefan/BackupsAndSettings/keepassx/BackupDrive.key luksOpen /dev/sdb1 enc_bk
			    vgchange -ay backupvg
				mount /dev/backupvg/BACKUP	/local/backup
			fi
		else
			echo "Backup drive not installed"	| tee -a ${LOG_ROOT}/${LOGFILENAME}
		fi	
    fi	
    if [ ! -L /links/backup ]
    then 
      echo "creating link /links/backup" | tee -a ${LOG_ROOT}/${LOGFILENAME}
      ln -sf /local/backup /links/backup
    fi	
 
fi 

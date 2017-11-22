#!/bin/bash
while getopts ":oc" OPTNAME
do
	case "${OPTNAME}" in
	  "o")
		echo "opening USB drive"
		#cryptsetup open /dev/sdb3 USBDrive
		cryptsetup luksOpen /dev/sdb3 USBDrive
		vgchange -a y VG_BACKUP
		sleep 5
		mount /dev/VG_BACKUP/LV_BACKUP /local/backup
		;;
	  "c")
		echo "closing USB drive"
		umount /local/backup
		vgchange -a n VG_BACKUP
		#cryptsetup close USBDrive
		cryptsetup luksClose USBDrive
		;;
	  "?")
		echo "Unknown option $OPTARG"
		;;
	  ":")
		echo "No argument value for option $OPTARG"
		;;
	  *)	
		echo "you need to specify -o for open or -c for close"
	  	;;
	 esac
echo "OPTIND is now $OPTIND"	 
done

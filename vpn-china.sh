#!/bin/bash
echo "routing table before"
echo $(netstat -rn)
while getopts ":oc" OPTNAME
do
	case "${OPTNAME}" in
	  "o")
		echo "opening China VPN"
		openvpn --config /links/workdata/Infrastructure/ChinaVPN/ccs-test-cloud/ccs-cloud.ovpn & 
		;;
	  "c")
		echo "closing china vpn"
		kill $(ps aux | grep '[c]cs-cloud.ovpn' | awk '{print $2}')
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
#echo "OPTIND is now $OPTIND"	 
done
echo "routing table after"
echo $(netstat -rn)




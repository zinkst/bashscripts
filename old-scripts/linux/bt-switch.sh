#!/bin/bash
while getopts ":ed" OPTNAME
do
	case "${OPTNAME}" in
	  "e")
		echo "enabling bluetooth"
		echo enable > /proc/acpi/ibm/bluetooth
		;;
	  "d")
		echo "disabling bluetooth"
		echo disable > /proc/acpi/ibm/bluetooth
		;;
	  "?")
		echo "Unknown option $OPTARG"
		;;
	  ":")
		echo "No argument value for option $OPTARG"
		;;
	  *)
	  # Should not occur
		echo "Unknown error while processing options"
		;;
	esac
echo "OPTIND is now $OPTIND"
done

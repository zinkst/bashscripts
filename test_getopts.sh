#!/bin/bash

# intialize input Parameters (may be overwritten)
IMAGENAME=init.tgz
VMHOSTNAME=initvm
IMAGEPATH=/vol/sapcds/testenv/backups/
IMAGESERVER=d2705nas1a


while getopts ":i:v:p:s:h" OPTNAME
  do
    case "${OPTNAME}" in
      "h")
        echo "Option ${OPTNAME} is specified"
        echo "call ${0} [-i <IMAGENAME> ] [-v <VMHOSTNAME>] [-p <IMAGEPATH>] [-s <IMAGESERVER>]"
        echo "defaults are:"
        echo "IMAGENAME=${IMAGENAME}"
        echo "VMHOSTNAME=${VMHOSTNAME}"
        echo "IMAGEPATH=${IMAGEPATH}"
        echo "IMAGESERVER=${IMAGESERVER}"
        exit 0; 
        ;;
      "i")
        echo "Option ${OPTNAME} is specified"
        IMAGENAME=${OPTARG} 
        ;;
      "v")
        echo "Option ${OPTNAME} is specified"
        VMHOSTNAME=${OPTARG} 
        ;;
      "p")
        echo "Option ${OPTNAME} is specified"
        IMAGEPATH=${OPTARG} 
        ;;
      "s")
        echo "Option ${OPTNAME} is specified"
        IMAGESERVER=${OPTARG} 
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

IMAGE=${IMAGEPATH}${IMAGENAME}
SOURCE=/nfsmnt
TARGET=/vmware/${VMHOSTNAME}
VMWAREGUEST_VMX=${TARGET}/ccmdbadminsrv/ccmdbadminsrv.vmx



echo "IMAGENAME	 	=${IMAGENAME}"
echo "VMHOSTNAME 	=${VMHOSTNAME}"
echo "IMAGEPATH	 	=${IMAGEPATH}"
echo "IMAGE	 	=${IMAGE}"
echo "IMAGESERVER	 	=${IMAGESERVER}"
echo "SOURCE	 	=${SOURCE}"
echo "TARGET	 	=${TARGET}"
echo "VMWAREGUEST_VMX 	=${VMWAREGUEST_VMX}"


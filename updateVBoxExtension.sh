#!/bin/bash
DOWNLOAD_DIR=${HOME}/Downloads
if [ ! -d ${DOWNLOAD_DIR} ]; 
then 
	mkdir ${DOWNLOAD_DIR}
fi	

version=$(vboxmanage -v)
#5.0.16_RPMFusionr105871
echo $version
var1=$(echo $version | awk -F "_RPMFusionr" '{ print $1 }' ) 
echo $var1
var2=$(echo $version | cut -d 'r' -f 2)
echo $var2
EXTPACK_FILENAME="Oracle_VM_VirtualBox_Extension_Pack-$var1-$var2.vbox-extpack"
echo ${EXTPACK_FILENAME}
if [ ! -f ${DOWNLOAD_DIR}/${EXTPACK_FILENAME} ]; then
	echo "${DOWNLOAD_DIR}/${EXTPACK_FILENAME} does not exit we need to update"
	echo "remove old Extpack files"
	rm -f ${DOWNLOAD_DIR}/Oracle_VM_VirtualBox_Extension_Pack*
	#http://download.virtualbox.org/virtualbox/5.0.16/Oracle_VM_VirtualBox_Extension_Pack-5.0.16-105871.vbox-extpack
	wget ***: download.virtualbox.org/virtualbox/$var1/${EXTPACK_FILENAME} -O ${DOWNLOAD_DIR}/${EXTPACK_FILENAME}
	#sudo VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
	cmd='VBoxManage extpack install '${DOWNLOAD_DIR}/${EXTPACK_FILENAME}' --replace'
	echo ${cmd}
	eval ${cmd}
else
	echo "${DOWNLOAD_DIR}/${EXTPACK_FILENAME} exists everything should be up to date"
fi	

#!/bin/bash
DOWNLOAD_DIR=${HOME}/Downloads
if [ ! -d ${DOWNLOAD_DIR} ]; 
then 
	mkdir ${DOWNLOAD_DIR}
fi	

installedVBoxVersion=$(vboxmanage -v | awk -F'_rpmfusionr' '{print $1}' )
availableExtVersion=$(wget -qO - https://download.virtualbox.org/virtualbox/LATEST.TXT)
installedExtVersion=$(vboxmanage list extpacks | grep Version | (read s; s=${s##Version:} ; echo $s))
# var1=$(echo $version | awk -F "_rpmfusionr" '{ print $1 }' ) 
echo installedExtVersion=$installedExtVersion
echo installedVBoxVersion=$installedVBoxVersion
echo availableExtVersion=${availableExtVersion}
# var2=$(echo $version | cut -d 'r' -f 2)
# echo var2=$var2{}
EXTPACK_FILENAME="Oracle_VM_VirtualBox_Extension_Pack-${installedVBoxVersion}.vbox-extpack"
echo ${EXTPACK_FILENAME}
if [ "${installedVBoxVersion}" != "${installedExtVersion}" ]; then
	echo "We need to update"
	#http://download.virtualbox.org/virtualbox/5.0.16/Oracle_VM_VirtualBox_Extension_Pack-5.0.16-105871.vbox-extpack
	wget ***: download.virtualbox.org/virtualbox/${installedVBoxVersion}/${EXTPACK_FILENAME} -O ${DOWNLOAD_DIR}/${EXTPACK_FILENAME}
	#sudo VBoxManage extpack uninstall "Oracle VM VirtualBox Extension Pack"
	cmd='echo y | VBoxManage extpack install '${DOWNLOAD_DIR}/${EXTPACK_FILENAME}' --replace'
	echo ${cmd}
	eval ${cmd}
	rm "${DOWNLOAD_DIR}/${EXTPACK_FILENAME}"
else
	echo "already up to date"
fi	

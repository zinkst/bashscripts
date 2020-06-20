#!/bin/bash	
BKP_DIR=${HOME}/Stefan-local/BackupsAndSettings/GnomeBackup


function backup {
  #cp -prv .local/share/gnome-shell/extensions ${BKP_DIR)/ 
  dconf dump /org/gnome/ > ${BKP_DIR}/org_gnome.dconf
}

function restore {
	#dconf reset -f /org/gnome/
	dconf dump /org/gnome/ < ${BKP_DIR}/org_gnome.dconf
}

function setup_gnome {
	gsettings set org.gnome.desktop.interface enable-hot-corners false
	gsettings set org.gnome.desktop.background picture-options scaled
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
}

#main
backup
#restore

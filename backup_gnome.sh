#!/bin/bash	
BKP_DIR=${HOME}/local/BackupsAndSettings/GnomeBackup

function backup {
  #cp -prv .local/share/gnome-shell/extensions ${BKP_DIR)/ 
  if [ ! -d ${BKP_DIR} ];  then
	  mkdir -p ${BKP_DIR}
  fi	
  dconf dump /org/gnome/ > ${BKP_DIR}/org_gnome.dconf
  dconf dump /org/gnome/shell/extensions/ > ${BKP_DIR}/org_gnome_shell_extensions.dconf
}

function restore {
  #dconf reset -f /org/gnome/
	dconf load/org/gnome/ < ${BKP_DIR}/org_gnome.dconf
	dconf load/org/gnome/shell/extensions/ < ${BKP_DIR}/org_gnome_shell_extensions.dconf
	setup_gnome
}

function setup_gnome {
	gsettings set org.gnome.desktop.interface enable-hot-corners false
	gsettings set org.gnome.desktop.background picture-options scaled
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
	gsettings set org.gnome.desktop.session idle-delay 0
	gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
	gsettings set org.gnome.desktop.screensaver lock-enabled false
	gsettings set org.gnome.desktop.interface show-battery-percentage true
}

# main
while getopts "sbc" OPTNAME
do
  case "${OPTNAME}" in
    "s")
      echo "Option setup_gnome ${OPTNAME} is specified"
      setup_gnome
      ;;
    "b")
      echo "Option backup ${OPTNAME} is specified"
      backup
      ;;
    "c")
      echo "Option restore ${OPTNAME} is specified"
      restore
      ;;
  
  esac
  #echo "OPTIND is now $OPTIND"
done

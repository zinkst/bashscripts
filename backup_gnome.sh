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
	dconf load /org/gnome/ < ${BKP_DIR}/org_gnome.dconf
	dconf load /org/gnome/shell/extensions/ < ${BKP_DIR}/org_gnome_shell_extensions.dconf
	setup_gnome
}

function setup_gnome {
	gsettings set org.gnome.desktop.interface enable-hot-corners false
	gsettings set org.gnome.desktop.background picture-options scaled
	gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
	gsettings set org.gnome.desktop.session idle-delay 600
	gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
	gsettings set org.gnome.desktop.notifications show-in-lock-screen true
	gsettings set org.gnome.desktop.interface show-battery-percentage true
  gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Alt>Tab', '<Alt>Above_Tab']"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "[]"
  gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
  gsettings set org.gnome.desktop.lockdown disable-lock-screen 'true'
  gsettings set org.gnome.mutter attach-modal-dialogs false
  if [ $(hostname -s) != "zinkstp" ]; then
    gsettings set org.gnome.desktop.screensaver lock-enabled false
  fi  
}

# main
while getopts "sbr" OPTNAME
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
    "r")
      echo "Option restore ${OPTNAME} is specified"
      restore
      ;;
  
  esac
  #echo "OPTIND is now $OPTIND"
done

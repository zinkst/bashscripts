#!/bin/bash	
BKP_DIR=${HOME}/lokal/BackupsAndSettings/KdeBackup

function backup {
  [[ -d ${BKP_DIR} ]] || mkdir -p ${BKP_DIR}
  #dconf dump /org/gnome/shell/extensions/ > ${BKP_DIR}/org_gnome_shell_extensions.dconf
  [[ -d ${BKP_DIR}/.config ]] || mkdir -p ${BKP_DIR}/.config
  cp ${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc ${BKP_DIR}/.config/
}

function restore {
  #dconf load/org/gnome/ < ${BKP_DIR}/org_gnome.dconf
  setup_kde
  cp ${BKP_DIR}/.config/plasma-org.kde.plasma.desktop-appletsrc ${HOME}/.config/ 
}

function setup_kde {
	echo ""
	#gsettings set org.gnome.desktop.interface show-battery-percentage true
}

# main
while getopts "sbr" OPTNAME
do
  case "${OPTNAME}" in
    "s")
      echo "Option setup_kde ${OPTNAME} is specified"
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

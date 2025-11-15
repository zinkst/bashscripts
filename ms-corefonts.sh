#!/bin/bash

function downloadCorefonts() {
  fontList=(
    "http://downloads.sourceforge.net/corefonts/andale32.exe"
    "http://downloads.sourceforge.net/corefonts/arial32.exe"
    "http://downloads.sourceforge.net/corefonts/arialb32.exe"
    "http://downloads.sourceforge.net/corefonts/comic32.exe"
    "http://downloads.sourceforge.net/corefonts/courie32.exe"
    "http://downloads.sourceforge.net/corefonts/georgi32.exe"
    "http://downloads.sourceforge.net/corefonts/impact32.exe"
    "http://downloads.sourceforge.net/corefonts/times32.exe"
    "http://downloads.sourceforge.net/corefonts/trebuc32.exe"
    "http://downloads.sourceforge.net/corefonts/verdan32.exe"
    "http://downloads.sourceforge.net/corefonts/webdin32.exe"
  )
  
  for i in "${fontList[@]}"
  do
    wget "$i" -O

  done

}

function installMSFonts() {
    dnf -y install cabextract
    wget https://www.freedesktop.org/software/fontconfig/webfonts/webfonts.tar.gz
    tar -xzf webfonts.tar.gz
    pushd msfonts
    cabextract *.exe
    mkdir -p /usr/share/fonts/ms-ttf-fonts
    cp *.ttf *.TTF /usr/share/fonts/ms-ttf-fonts/
    popd
    rm -rf msfonts
    rm -f webfonts.tar.gz 
}

# main
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
# downloadCorefonts # other method is better
installMSFonts

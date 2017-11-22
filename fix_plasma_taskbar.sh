#!/bin/bash
#fix taskbar in KDE Plasma
sed -i "0,/lastScreen=./s//lastScreen=0/" ${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc
kquitapp5 plasmashell ; /usr/bin/plasmashell --shut-up &

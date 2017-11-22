#!/bin/bash

# Set Fonts 
if ! rpm -q liberation-fonts  >/dev/null 2>&1; then
  echo "Please install the package liberation-fonts"
  exit 0
fi

case "$1" in
        default)
	gconftool-2 --set /apps/nautilus/preferences/desktop_font --type string "Sans 10"
	gconftool-2 --set /desktop/gnome/interface/document_font_name --type string "Sans 10"
	gconftool-2 --set /desktop/gnome/interface/font_name --type string "Sans 10"
	gconftool-2 --set /apps/metacity/general/titlebar_font --type string "Sans Bold 10"
	gconftool-2 --set /desktop/gnome/interface/monospace_font_name --type string "Monospace 10"
	;;
        liberation)
	gconftool-2 --set /apps/nautilus/preferences/desktop_font --type string "Liberation Sans 9"
	gconftool-2 --set /desktop/gnome/interface/document_font_name --type string "Liberation Sans 9"
	gconftool-2 --set /desktop/gnome/interface/font_name --type string "Liberation Sans 9"
	gconftool-2 --set /apps/metacity/general/titlebar_font --type string "Liberation Sans Bold 9"
	gconftool-2 --set /desktop/gnome/interface/monospace_font_name --type string "Liberation Mono 9"
	;;
	*)
	echo "Please run ./set-fonts.sh default or ./set-fonts.sh liberation"
	;;
esac

exit $?


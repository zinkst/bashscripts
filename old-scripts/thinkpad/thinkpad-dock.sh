#!/bin/sh
# wait for the dock state to change
sleep 2
DOCKED=$(cat /sys/devices/platform/dock.1/docked)
case "$DOCKED" in
	"0")
	#undocked event - lets remove all connected outputs apart from LVDS
	#for output in $(/usr/bin/xrandr -d :0.0 --verbose|grep " connected"|grep -v LVDS|awk '{print $1}')
	#  do
	#  /usr/bin/xrandr -d :0.0 --output $output --off
	#done
	echo " undocked" > ~/thinkpad-dock.log
    #/links/bashscripts/ati_enable_monitor.sh 1
    # currently dock detection does not work, so defaulting to undocked
    /links/bin/nvidia_enable_monitor.sh 1
	;;
	"1")
	#docked event
	#/usr/bin/xrandr -d :0.0 --output DVI1 --right-of LVDS1 --auto
	echo " docked" > ~/thinkpad-dock.log
    /links/bin/nvidia_enable_monitor.sh 2
	;;
esac
#alsactl restore
exit 0

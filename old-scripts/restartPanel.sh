#!/bin/bash
# http://www.howtogeek.com/howto/linux/reload-the-gnome-or-kde-panels-without-restarting/
#dcop kicker kicker restart
#killall kicker
#kicker
kwin --replace &

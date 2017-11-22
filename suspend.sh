!/bin/bash
# suspends us via acpi

if [ -r /etc/sysconfig/laptop ]; then
    . /etc/sysconfig/laptop
fi

. /etc/acpi/actions/functions

# pre-suspend actions here
rchotplug stop
rcnetwork stop
rmmod e1000
rmmod ipw2100
rmmod nvram

# suspend
echo 3 > /proc/acpi/sleep

# when this returns, we are resuming
sleep 2
modprobe e1000
modprobe ipw2100
modprobe nvram
rcnetwork start
rchotplug start
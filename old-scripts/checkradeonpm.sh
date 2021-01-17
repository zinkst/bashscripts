#!/bin/bash
echo "power_method : "  `cat /sys/class/drm/card0/device/power_method`
echo "power_profile: "  `cat /sys/class/drm/card0/device/power_profile`
mkdir /debugfs
mount -t debugfs debugfs /debugfs
cat /debugfs/dri/0/radeon_pm_info
umount /debugfs
rmdir /debugfs  

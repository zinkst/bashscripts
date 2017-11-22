#!/bin/bash
export NEW_ROOT=/local/RHEL7/
mount --bind /proc ${NEW_ROOT}/proc
mount --bind /dev ${NEW_ROOT}/dev
mount --bind /sys ${NEW_ROOT}/sys
chroot ${NEW_ROOT}

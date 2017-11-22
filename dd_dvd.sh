#!/bin/bash
umount /dev/sr0
echo "starting dd on $(date +%H:%M:%S)"
dd if=/dev/sr0 of="\"/links/DVDs/permanent/${1}\""
echo "stopping dd on $(date +%H:%M:%S)"

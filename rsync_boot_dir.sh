#!/bin/bash
mkdir -p /boot_bkp
/usr/bin/rsync -A -X -av -d /boot/* /boot_bkp/


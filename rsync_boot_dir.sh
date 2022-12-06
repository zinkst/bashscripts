#!/bin/bash
mkdir -p /boot_bkp
/usr/bin/rsync -A -X -av /boot/* /boot_bkp/


#!/bin/bash
ls -lZ  /home/zinks/.local/share/icc/
semanage fcontext -a -t icc_data_home_t "/home/zinks/.local/share/icc/edid-*.icc"
/sbin/restorecon -v "/home/zinks/.local/share/icc/edid-*.icc"

#!/bin/bash

NONSYSTEM_USERS=$(getent passwd {1000..10000} | cut -d ":" -f1)
for u in ${NONSYSTEM_USERS} 
do 
  if [ ! -f /home/${u}/.cache/CACHEDIR.TAG ]; then
    echo Adding CACHEDIR.TAG for user $u
    cat << EOF > /home/${u}/.cache/CACHEDIR.TAG
Signature: 8a477f597d28d172789f06886806bc55
# This file is a cache directory tag created by (application name).
# For information about cache directory tags, see:
#	http://www.brynosaurus.com/cachedir/EOF
EOF
    chown ${u}:users /home/${u}/.cache/CACHEDIR.TAG
  fi
  ls -l /home/${u}/.cache/CACHEDIR.TAG
done  
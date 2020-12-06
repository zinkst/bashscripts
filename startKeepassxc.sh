#!/bin/bash
# enter secret into database
#secret-tool store --label='Keepass' database Keepass.kdbx
secret-tool lookup database Keepass.kdbx > /dev/null
if [ $? -eq 0 ]; then
  echo "lookup successful"
  secret-tool lookup database Keepass.kdbx | env QT_QPA_PLATFORM=xcb keepassxc --pw-stdin ~/Dokumente/privat/access_store/stefans &
else 
  echo "lookup unsuccessful"
  env QT_QPA_PLATFORM=xcb keepassxc $1 &
fi
# secret-tool lookup database Keepass.kdbx | keepassxc-cli show -s -q -a Password ~/Dokumente/privat/access_store/stefans alpenvereinaktiv.com 

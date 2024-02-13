#!/bin/bash
# enter secret into database
# secret-tool store --label='BW_CLIENTID' database BW_CLIENTID
# secret-tool store --label='BW_CLIENTSECRET' database BW_CLIENTSECRET

source /links/bin/bitwardenFunctions.sh

# main
# bw config server https://zinks.dnshome.de:44300/vaultwarden/
export BW_CLIENTID=$(secret-tool lookup database 'BW_CLIENTID')
export BW_CLIENTSECRET=$(secret-tool lookup database 'BW_CLIENTSECRET')
export BW_MASTERPASSWORD=$(secret-tool lookup database 'vaultwarden')
export BW_USER="stefan@zink.bw"
bitwardenLogin $@
bw get password "${1}"
#!/bin/bash
# enter secret into database
#secret-tool store --label='vaultwarden' database vaultwarden
secret-tool lookup database BW_MASTERPASSWORD | wl-copy 

#!/bin/bash

#main
export OP_MASTER_PWD=$(secret-tool lookup OP_MASTER_PWD OP_MASTER_PWD)
eval $(echo $OP_MASTER_PWD | op signin --account ibm)
export RESTIC_PASSWORD=$(op read "op://IBM Corporate/restic-backup/password")
export RESTIC_REPOSITORY='rclone:szboxbackup:restic'

# restic --verbose --password-command "op read 'op://IBM Corporate/restic-backup/password'" snapshots
restic --verbose --password-command "op read 'op://IBM Corporate/restic-backup/password'" backup /local/data/${hostname -s}/sysbkp
eval $(echo $OP_MASTER_PWD | op signin --account ibm)
restic --verbose --password-command "op read 'op://IBM Corporate/restic-backup/password'" backup /local/data/workdata
eval $(echo $OP_MASTER_PWD | op signin --account ibm)
restic --verbose --password-command "op read 'op://IBM Corporate/restic-backup/password'" backup /home/zinks --one-file-system --exclude-file="/links/bin/zinkstp/restic-exclude.txt"
exit 0

#!/bin/bash

#main
export OP_MASTER_PWD=$(secret-tool lookup OP_MASTER_PWD OP_MASTER_PWD)
eval $(echo $OP_MASTER_PWD | op signin --account ibm)
export RESTIC_PASSWORD=$(op read "op://IBM Corporate/restic-backup/password")
export RESTIC_REPOSITORY='rclone:szboxbackup:restic'


function mountRestic (){
	ind=${1}
	mkdir -p $HOME/restic-mount
	cmd="restic mount --path ${1} ${HOME}/restic-mount"
	echo "$cmd"
	eval "$cmd" 
}


#restic --verbose --password-command "op read 'op://IBM Corporate/restic-backup/password'" snapshots
mountRestic /home/zinks
ls -l $HOME/restic-mount
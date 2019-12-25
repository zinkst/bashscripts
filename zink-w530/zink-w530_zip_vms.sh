#!/bin/bash
source /links/bin/bkp_functions.sh

DATESTRING=$(date +'%Y%m%d')
src_dir="/"
bkp_dir="/links/sysbkp"
CORRECTHOST="marion-pc"
checkCorrectHost
usePigz=true
usePigz=false

#src[1]=${src_dir}links/vms/windows8-virt/windows8-virt.vdi
#tgt[1]=${bkp_dir}/${CORRECTHOST}_${DATESTRING}_windows8-virt.vdi

src[0]=${src_dir}local/ntfs_c/vhds/marion-pc_win10pro.vhd
tgt[0]=${bkp_dir}/${CORRECTHOST}_${DATESTRING}_marion-pc_win10pro.vhd

execute_command=(false false)
index=(0)

compressCommand () 
{
  if [ ${usePigz} == true ]
  then
	command="pigz --best -c ${src[$1]} > ${tgt[$1]}.gzip"
  else
	command="7za a ${tgt[$1]}.7z ${src[$1]} "
  fi
}	

read -p "Backup all vhds or step throug each individually (a/i)?" ALL
echo "starting backup at:"
date
if [ "$ALL" == "a" ]; then
	for i in "${index[@]}"
	do
		compressCommand $i
		echo "executing ${command}"
		eval ${command}
	done
else
	#loop through execution questions
	for i in "${index[@]}"
	do
		compressCommand $i
		echo "${command}"
		read -p "Execute command above (y/n)?" CONT
		if [ "$CONT" == "y" ]; then
			echo "trigger execution of ${command[$i]}";
			execute_command[$i]=true
		fi
		#echo "execute_command[$i] = ${execute_command[$i]}"
	done	
	
	# loop through demanded executions
	for i in "${index[@]}"
	do
		if [ ${execute_command[$i]} == true ];
		then
			compressCommand $i
			echo "executing command ${command}"
			eval ${command}
		fi
	done	
fi
echo "backup finshed at:"
date



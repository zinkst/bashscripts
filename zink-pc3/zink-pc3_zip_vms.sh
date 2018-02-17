#!/bin/bash
DATESTRING=$(date +'%Y%m%d')
src_dir="/local/ntfs_c/vhds"
bkp_dir="/links/sysbkp"
usePigz=false

src[0]=${src_dir}/win10.vhd
tgt[0]=${bkp_dir}/${DATESTRING}_win10.vhd
src[1]="/links/data/zink-pc3/VirtualBox\ VMs/Windows10/Windows10.vdi"
tgt[1]=${bkp_dir}/${DATESTRING}_Windows10.vdi



execute_command=(false false false false false)
index=(0 1)

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
		#eval ${command}
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

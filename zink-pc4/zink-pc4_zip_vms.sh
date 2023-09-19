#!/bin/bash
DATESTRING=$(date +'%Y%m%d')
src_dir="/local/ntfs_c/vhds"
bkp_dir="/links/sysbkp"
usePigz=false

src[0]=${src_dir}/win11.vhd
tgt[0]=${bkp_dir}/${DATESTRING}_$(hostname -s)_win11.vhd



execute_command=(false false false false false)
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

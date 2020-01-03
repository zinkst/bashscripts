#!/bin/bash
DATESTRING=$(date +'%Y%m%d')
src_dir="/local/ntfsdata/vhds"
bkp_dir="/links/sysbkp"
usePigz=true
usePigz=false

src[0]=/local/ntfs_c/vhds/win10_pro_ssd.vhd
tgt[0]=${bkp_dir}/${DATESTRING}_win10_pro_ssd.vhd

src[1]=${src_dir}/ddrive.vhd
tgt[1]=${bkp_dir}/${DATESTRING}_ddrive.vhd

src[2]=/local/ntfsdata/vhds/kinder_win10_pro_hdd.vhd
tgt[2]=${bkp_dir}/${DATESTRING}_kinder_win10_pro_hdd.vhd

src[3]=/links/vms/VB/Win81-zinksrv-vm/win81_pro_zinksrv.vhd
tgt[3]=${bkp_dir}/${DATESTRING}_win81_pro_zinksrv.vhd

src[4]=/links/vms/VB/w7-ultimate-64/W7-ultimate-64.vhd
tgt[4]=${bkp_dir}/${DATESTRING}_W7-ultimate-64.vhd

src[5]=${src_dir}/W7-Games-Ultimate.vhd
tgt[5]=${bkp_dir}/${DATESTRING}_W7-Games-Ultimate.vhd



execute_command=(false false false false false)
index=(0 1 2 )

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

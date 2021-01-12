#!/bin/bash
index=(01 02 03 04 05 06 07 08 09 10 11 12)
basedir="/local/ssd-data/Photos"
year=$(date +%Y)

for i in ${index[@]}
do
	curDir=${basedir}"/"${year}
	if [ ! -d ${curDir}/${year}${i} ] 
	then
		cmd="mkdir -p ${curDir}/${year}${i}"
		echo ${cmd}
		eval ${cmd}
	fi	
done		
ls -l ${basedir}"/"${year}

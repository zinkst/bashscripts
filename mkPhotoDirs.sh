#!/bin/bash
function createFavoritenInfoFile() {
tgtFolder="${1}"
if [ ! -f "${tgtFolder}/FavoritenInfo.yml" ]; then
	cat << EOF > "${tgtFolder}/FavoritenInfo.yml"
rootSubFolder: Familie Zink
yearSubFolder: ${year}00_Sonstige
EOF
fi
}


index=(01 02 03 04 05 06 07 08 09 10 11 12)
basedir="/local/ssd-data/Photos"
year=${year:-$(date +%Y)}

for i in ${index[@]}
do
	curDir=${basedir}"/"${year}
	if [ ! -d ${curDir}/${year}${i} ] 
	then
		cmd="mkdir -p ${curDir}/${year}${i}"
		echo ${cmd}
		eval ${cmd}
		createFavoritenInfoFile "${curDir}/${year}${i}"
	fi	
done		
ls -l ${basedir}"/"${year}

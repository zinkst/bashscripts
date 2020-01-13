#!/bin/sh
#files=$(pushd ${HOME}/bin/home/linux && ls .*)
export SRC_DIR="/links/bin/DesktopFiles"
export TGT_DIR="${HOME}/.local/share/applications"
pushd $SRC_DIR
#files=$(find . -type f -exec echo " {}"\; | tr -d '\n' | cut -d '/' -f2)
#find . -type f -printf "%p" | IFS=./ read -a files
files=($(ls *.desktop))

for i in "${files[@]}"; 
do 
    #echo "$i"
    if [ ! -f "${TGT_DIR}/$i" ];
    then 
        cmd="ln -sf \"${SRC_DIR}/$i\" \"${TGT_DIR}/$i\""
        echo $cmd
        eval $cmd
    fi     
done
popd


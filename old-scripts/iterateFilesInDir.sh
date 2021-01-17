#!/bin/sh
#files=$(pushd ${HOME}/bin/home/linux && ls .*)
export SRC_DIR="${HOME}/bin/home/linux"
export TGT_DIR="${HOME}"
pushd $SRC_DIR
#files=$(find . -type f -exec echo " {}"\; | tr -d '\n' | cut -d '/' -f2)
#find . -type f -printf "%p" | IFS=./ read -a files
files=($(ls))

for i in "${files[@]}"; 
do 
    #echo "$i"
    # cmd="mv \"${TGT_DIR}/.$i\" \"${TGT_DIR}/$i.bkp\""
    # echo $cmd
    # eval $cmd
    cmd="ln -sf \"${SRC_DIR}/$i\" \"${TGT_DIR}/.$i\""
    echo $cmd
    eval $cmd  
done
popd


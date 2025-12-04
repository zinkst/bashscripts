#!/bin/bash
WORK_DIR="/local/data/Other-Systems/Karl-Laptop"
find ${WORK_DIR}/sysbkp -name "karl-laptop*.vhd" -exec echo {} \; #&& rm {} \; 
find ${WORK_DIR} -name "karl-laptop*.vhd" -exec 7z a {}.7z {} \; #&& rm {} \; 

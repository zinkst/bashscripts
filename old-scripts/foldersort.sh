#!/bin/bash
if [ -n ${WINEPREFIX} ] 
then    
    WINEPREFIX=${HOME}
fi	
echo WINEPREFIX = ${WINEPREFIX}
wine $WINEPREFIX/.wine/drive_c/Program\ Files/FolderSort/FolderSort.exe &

#!/bin/bash
DRIVE_C_DIR="/home/wine/drive_c/windows/fonts/"
FONTS_DIR="/home/share/fonts/"

Fonts[1]="arialbd.ttf"
Fonts[2]="arialbi.ttf"
Fonts[3]="ariali.ttf"
Fonts[4]="arialnbi.ttf"
Fonts[5]="arialnb.ttf"
Fonts[6]="arialni.ttf"
Fonts[7]="arialn.ttf"
Fonts[8]="arial.ttf"
Fonts[9]="ariblk.ttf"
Fonts[10]="lsansdi.ttf"
Fonts[11]="lsansd.ttf"
Fonts[12]="lsansi.ttf"
Fonts[13]="lsans.ttf"
Fonts[14]="timesbd.ttf"
Fonts[15]="timesbi.ttf"
Fonts[16]="timesi.ttf"
Fonts[17]="times.ttf"
Fonts[18]="comicbd.ttf"
Fonts[19]="comic.ttf"
Fonts[20]="courbd.ttf"
Fonts[21]="courbi.ttf"
Fonts[22]="couri.ttf"
Fonts[23]="cour.ttf"
Fonts[24]="georgiab.ttf"
Fonts[25]="georgiai.ttf"
Fonts[26]="georgia.ttf"
Fonts[27]="georgiaz.ttf"
Fonts[28]="impact__.ttf"
Fonts[29]="impact.ttf"
Fonts[30]="trebucbd.ttf"
Fonts[31]="trebucbi.ttf"
Fonts[32]="trebucit.ttf"
Fonts[33]="trebuc.ttf"
Fonts[34]="webdings.ttf"

FontsArraySize=${#Fonts[@]}
echo ${FontsArraySize}
index=1

while [ "$index" -le "$FontsArraySize" ]
do
  curFont=${Fonts[$index]}
  #echo "processing font: ${curFont}"
  cmd="ln -sf ${FONTS_DIR}${curFont} ${DRIVE_C_DIR}${curFont}"
  echo $cmd
  $cmd
  let "index= $index+1"	 
done

  

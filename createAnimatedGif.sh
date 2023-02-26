#!/bin/bash
pwd
SRC_PATTERN="20221231_142441_0*"
TGT_NAME="myimage.gif"
convert -resize 30% -delay 8 -loop 0 ${SRC_PATTERN} ${TGT_NAME}
mogrify -layers 'optimize' -fuzz 5% ${TGT_NAME}

#!/bin/sh
export SRC_DIR="/links/bin/DesktopFiles"
export TGT_DIR="${HOME}/.local/share/applications"
export DESKTOP_FILE="Signal-Minimized.desktop"
cmd="ln -sf \"${SRC_DIR}/${DESKTOP_FILE}\" \"${TGT_DIR}/${DESKTOP_FILE}\""
echo $cmd
eval $cmd
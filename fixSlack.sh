#!/bin/bash
set -euo pipefail

sudo cp /usr/lib/slack/resources/app.asar /usr/lib/slack/resources/app.asar.backup
sudo sed -i -e 's/,"WebRTCPipeWireCapturer"/,"LebRTCPipeWireCapturer"/' /usr/lib/slack/resources/app.asar
ls -l /usr/lib/slack/resources/app.a*
#cp /usr/share/applications/slack.desktop ${HOME}/.local/share/applications/
#sed -i -e 's#Exec=/usr/bin/slack %U#Exec=/usr/bin/slack\ %U\ --enable-features=WebRTCPipeWireCapturer#' ${HOME}/.local/share/applications/slack.desktop
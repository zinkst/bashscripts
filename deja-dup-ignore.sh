#!/bin/bash

IGNORE_DIRS=(
  ~/.local/share/containers
  ~/.local/share/gnome-boxes
  ~/.cache
  ~/.config/Code/Cache
  ~/.config/Code/CachedConfigurations
  ~/.config/Code/CachedData
  ~/.config/Code/CachedExtensions
  ~/.config/Code/CachedExtensionVSIXs
  ~/.config/Code/CachedProfilesData
  ~/.config/google-chrome
  ~/.npm
  ~/.nvm/.cache
  ~/.freezer-cache
  ~/go/pkg/mod/cache
)

for DIR in "${IGNORE_DIRS[@]}"
do
  echo Processing ${DIR}
  if [ ! -f "${DIR}/.deja-dup-ignore" ]; then
    echo "creating ${DIR}/.deja-dup-ignore"
    touch "${DIR}/.deja-dup-ignore"
    chmod 400 "${DIR}/.deja-dup-ignore"
  else
    echo "${DIR}/.deja-dup-ignore already exists ... " && ls -l "${DIR}/.deja-dup-ignore"
  fi  
done
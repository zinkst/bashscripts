#/bin/bash
COMMAND="$1"
VERSION="$2"
export TARGET_DIR=${HOME}/.local/bin
pushd ${TARGET_DIR}
ls -l ${COMMAND}-versions/${COMMAND}*
if [ -z "$2" ]; then
  echo "which version do you want e.g. 3.14.1"
  read VERSION
fi
echo "setting up $COMMAND with ${VERSION}"  
if [ -e "${COMMAND}" ]; then
  echo "deleting old version of ${COMMAND}"
  rm "${COMMAND}"
fi  
if [ -f "${COMMAND}-versions/${COMMAND}-${VERSION}" ]; then
  chmod 755 "${COMMAND}-versions/${COMMAND}-${VERSION}"
  ln -sf ${COMMAND}-versions/${COMMAND}-${VERSION} ${COMMAND}
  echo "new ${COMMAND} version: ${VERSION}"
else
  echo "Version $VERSION does not exist"
fi
ls -l ${TARGET_DIR}/${COMMAND}
popd

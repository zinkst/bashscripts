#!/bin/bash
#export LETSENCYPT_CERTDIR=/etc/letsencrypt/live/yudzeedcramqfxzm.myfritz.net/
export LETSENCYPT_CERTDIR=/etc/letsencrypt/live/vfrcjfwqtztrwckg.myfritz.net/
export TGT_DIR="/links/Gemeinsam/Burghalde/HeimNetz/"
cd ${LETSENCYPT_CERTDIR}
cat cert.pem chain.pem privkey.pem > ${TGT_DIR}/letsencrypt_for_fritz.pem
chown zinks.users  ${TGT_DIR}/letsencrypt_for_fritz.pem
ls -l ${TGT_DIR}
echo "${TGT_DIR}/letsencrypt_for_fritz.pem needs to be imported into fritz.box using UI"


#!/bin/bash

function bitwardenLogin() {
  BW_STATUS=$(bw status | jq -r .status)
  case "$BW_STATUS" in
  "unauthenticated")
      echo "Logging into BitWarden"
      # export BW_SESSION=$(bw login ${BW_USER} --passwordenv BW_MASTERPASSWORD --raw)
      bw login --apikey --raw
      export BW_SESSION=$(bw unlock --passwordenv BW_MASTERPASSWORD --raw)
      ;;
  "locked")
      echo "Unlocking Vault"
      export BW_SESSION=$(bw unlock --passwordenv BW_MASTERPASSWORD --raw)
      ;;
  "unlocked")
      echo "Vault is unlocked"
      ;;
  *)
      echo "Unknown Login Status: $BW_STATUS"
      ;;
  esac

  unset BW_CLIENTID
  unset BW_CLIENTSECRET
  unset BW_MASTERPASSWORD
}


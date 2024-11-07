#!/bin/bash
set -euo pipefail

function installInfluxCli() {
  # see https://github.com/influxdata/influx-cli/releases
  wget https://download.influxdata.com/influxdb/releases/influxdb2-client-2.7.5-linux-amd64.tar.gz -O ~/Downloads/influxdb2-client.tgz
  mkdir -p /home/share/influx-cli
  tar -xzf ~/Downloads/influxdb2-client.tgz --directory /home/share/influx-cli
  ln -sf /home/share/influx-cli/influx /usr/local/bin/
}

function createInfluxConfig() {
  SERVER_NAME=$(hostname -s)
  influx config create \
    -n ${SERVER_NAME} \
    -u http://${SERVER_NAME}:8086 \
    -p influxadm:${ADMIN_PASSWORD}
}

function restoreInfluxDb() {
  # this doesn't work for unknown reasons
  influx restore /links/sysbkp/influx-zinksrv/latest/ --bucket home-assistant

}

# main
installInfluxCli
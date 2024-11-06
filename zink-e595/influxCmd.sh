#!/bin/bash

function installInfluxCli() {
  wget https://download.influxdata.com/influxdb/releases/influxdb2-client-2.7.5-linux-amd64.tar.gz -O ~/Downloads/influxdb2-client.tgz
  mkdir -p /home/share/influx-cli
  tar -xzf ~/Downloads/influxdb2-client.tgz --directory /home/share/influx-cli
  ln -sf /home/share/influx-cli/influx /usr/local/bin/
}

function createInfluxConfig() {
  influx config create \
    -n zink-e595 \
    -u http://zink-e595:8086 \
    -p influxadm:${ADMIN_PASSWORD}
}

function restoreInfluxDb() {
  influx restore /links/sysbkp/influx-zinksrv/latest/ --bucket home-assistant
}

# main
restoreInfluxDb

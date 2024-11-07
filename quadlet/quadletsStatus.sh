#!/bin/bash

QUADLET_SCRIPTS=(
caddyQuadlet.sh
grafanaQuadlet.sh
home-assistantQuadlet.sh
nextcloudQuadlets.sh
nodeExporterQuadlet.sh
prometheusQuadlet.sh
vaultwardenQuadlet.sh
zigbee2mqttQuadlet.sh
influxdbQuadlet.sh
)

for quadlet in "${QUADLET_SCRIPTS[@]}"
do
    /links/bin/quadlet/${quadlet} -s
done
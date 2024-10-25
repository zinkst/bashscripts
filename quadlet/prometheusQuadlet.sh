#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function CreateQuadlet() {
  mkdir -p ${PROMETHEUS_DATA_DIR}
  chmod 777 -R ${PROMETHEUS_DATA_DIR}
  chown -R 65534:65534 ${PROMETHEUS_DATA_DIR}
  chcon -t container_file_t ${PROMETHEUS_DATA_DIR}
  cat <<EOF > ${QUADLET_DIR}/${SERVICE_NAME}.container 
[Unit]
Description=${SERVICE_NAME}
Wants=network-online.target
After=network-online.target

[Container]
Label=app=${SERVICE_NAME}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=${SERVICE_NAME}
Image=${CONTAINER_IMAGE}
Network=${NETWORK_NAME}
PublishPort=${PROMETHEUS_HTTP_PORT}:9090
Volume=${PROMETHEUS_DATA_DIR}:/prometheus:Z
Volume=${PROMETHEUS_ETC_DIR}/prometheus:/etc/prometheus:Z
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam

[Install]
${START_ON_BOOT}
EOF
}

function CreatePrometheusConfig() {
  # inspired by https://medium.com/@netopschic/implementing-monitoring-stack-node-exporter-prometheus-grafana-on-fedora-using-podman-compose-6bc97d4c44a9
  mkdir -p ${PROMETHEUS_ETC_DIR}/prometheus
  # chown -R 65534:65534 ${PROMETHEUS_ETC_DIR}
  # chcon -t container_file_t ${PROMETHEUS_ETC_DIR}
  cat <<EOF > ${PROMETHEUS_ETC_DIR}/prometheus/prometheus.yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

scrape_configs:
  # The job name is added as a label job=<job_name> to any timeseries scraped from this config.
  - job_name: "prometheus"
    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
      - targets: ["localhost:9090"]
  - job_name: "node"
    static_configs:
      - targets: ["node-exporter:9100"]
EOF
}

function setEnvVars() {
  setDefaultEnvVars
  SERVICE_NAME="prometheus"
  PROMETHEUS_DATA_DIR="$(yq -r '.PROMETHEUS.DATA_DIR' "${CONFIG_YAML}")"
  PROMETHEUS_ETC_DIR="$(yq -r '.PROMETHEUS.ETC_DIR' "${CONFIG_YAML}")"
  SERVER_IP=$(hostname -I | awk '{print $1}')
  PROMETHEUS_HTTP_PORT="$(yq -r '.PROMETHEUS.HTTP_PORT' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  START_ON_BOOT="$(yq -r '.PROMETHEUS.START_ON_BOOT' "${CONFIG_YAML}")" 
  CONTAINER_IMAGE="$(yq -r '.PROMETHEUS.CONTAINER_IMAGE' "${CONFIG_YAML}")" 
}


function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo SERVER_IP=${SERVER_IP}
  echo PROMETHEUS_DATA_DIR=${PROMETHEUS_DATA_DIR}
  echo PROMETHEUS_ETC_DIR=${PROMETHEUS_ETC_DIR}
  echo PROMETHEUS_HTTP_PORT=${PROMETHEUS_HTTP_PORT}
  echo CONTAINER_IMAGE=${CONTAINER_IMAGE}
  echo START_ON_BOOT=${START_ON_BOOT}
}

function install() {
  CreatePodmanNetwork
  CreatePrometheusConfig
  CreateQuadlet
  postInstall
  showStatus
}

main "$@"

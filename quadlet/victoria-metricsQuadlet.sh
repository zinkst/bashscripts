#!/bin/bash
set -euo pipefail

source /links/bin/lib/quadletFunctions.sh

function CreateQuadlet() {
  mkdir -p ${VM_DATA_DIR}
  cat <<EOF > "${QUADLET_DIR}/${SERVICE_NAME}.container" 
[Unit]
Description=${SERVICE_NAME}
Wants=network-online.target
After=network-online.target

[Container]
Label=app=${SERVICE_NAME}
AutoUpdate=${PODMAN_AUTO_UPDATE_STRATEGY}
ContainerName=${SERVICE_NAME}
Image=${CONTAINER_IMAGE}
Exec=-retentionPeriod=10y -promscrape.config=/vm-etc/prometheus.yml -promscrape.config.strictParse=false
Network=${NETWORK_NAME}
PublishPort=${HTTP_PORT}:8428
Volume=${VM_DATA_DIR}:/victoria-metrics-data:Z
Volume=${VM_ETC_DIR}:/vm-etc:Z
Volume=/etc/localtime:/etc/localtime:ro
Environment=TZ=Europe/Amsterdam

[Service]
Restart=on-failure

[Install]
${START_ON_BOOT}
EOF
}

function CreatePrometheusConfig() {
  # inspired by https://medium.com/@netopschic/implementing-monitoring-stack-node-exporter-prometheus-grafana-on-fedora-using-podman-compose-6bc97d4c44a9
  mkdir -p ${VM_ETC_DIR}
  # chown -R 65534:65534 ${PROMETHEUS_ETC_DIR}
  # chcon -t container_file_t ${PROMETHEUS_ETC_DIR}
  cat <<EOF > ${VM_ETC_DIR}/prometheus.yml
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
  SERVICE_NAME="victoria-metrics"
  DATA_DIR="$(yq -r '.VICTORIA_METRICS.DATA_DIR' "${CONFIG_YAML}")"
  VM_DATA_DIR="${DATA_DIR}/data"
  VM_ETC_DIR="${DATA_DIR}/etc"
  HTTP_PORT="$(yq -r '.VICTORIA_METRICS.HTTP_PORT' "${CONFIG_YAML}")"
  PODMAN_AUTO_UPDATE_STRATEGY="$(yq -r '.HOST.PODMAN_AUTO_UPDATE_STRATEGY' "${CONFIG_YAML}")"
  START_ON_BOOT="$(yq -r '.VICTORIA_METRICS.START_ON_BOOT' "${CONFIG_YAML}")" 
  CONTAINER_IMAGE="$(yq -r '.VICTORIA_METRICS.CONTAINER_IMAGE' "${CONFIG_YAML}")" 
}


function printEnvVars() {
  printDefaultEnvVars
  echo PODMAN_AUTO_UPDATE_STRATEGY=${PODMAN_AUTO_UPDATE_STRATEGY}
  echo DATA_DIR=${DATA_DIR}
  echo HTTP_PORT=${HTTP_PORT}
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

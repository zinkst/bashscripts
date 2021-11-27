#!/bin/bash

function setDelegate() {
  sudo mkdir -p /etc/systemd/system/user@.service.d
  cat << EOF > /tmp/delegate.conf
[Service]
Delegate=yes
EOF
  sudo mv /tmp/delegate.conf /etc/systemd/system/user@.service.d/
  sudo systemctl daemon-reload
}

function containerRegistryShortNameMode () {
  echo 'short-name-mode="permissive"' > /tmp/001-permissive.conf
  sudo mv /tmp/001-permissive.conf /etc/containers/registries.conf.d/001-permissive.conf
}

function changeFirewall () {
  sudo sed -i 's/FirewallBackend=.*/FirewallBackend=iptables/' /etc/firewalld/firewalld.conf 
  sudo systemctl restart firewalld
}

function loadiptablesModules() {
  cat << EOF > /tmp/iptables.conf
ip6_tables
ip6table_nat
ip_tables
iptable_nat
EOF
  sudo mv /tmp/iptables.conf /etc/modules-load.d/iptables.conf
}

# main
# setDelegate
# containerRegistryShortNameMode
changeFirewall
#loadiptablesModules
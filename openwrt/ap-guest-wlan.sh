#!/bin/sh
function configureNetwork() {
  # Configure network
  uci -q delete network.${GUEST_DEV}
  uci set network.${GUEST_DEV}="device"
  uci set network.${GUEST_DEV}.type="bridge"
  uci set network.${GUEST_DEV}.name="${GUEST_BRIDGE}"
  uci -q delete network.${GUEST_NETWORK}
  uci set network.${GUEST_NETWORK}="interface"
  uci set network.${GUEST_NETWORK}.proto="static"
  uci set network.${GUEST_NETWORK}.device="${GUEST_BRIDGE}"
  uci set network.${GUEST_NETWORK}.ipaddr="192.168.3.1"
  uci set network.${GUEST_NETWORK}.netmask="255.255.255.0"
  uci commit network
  /etc/init.d/network restart
}

function configureWireless() {
  # Configure wireless
  WIFI_DEV="$(uci get wireless.@wifi-iface[0].device)"
  uci -q delete wireless.${GUEST_NETWORK}
  uci set wireless.${GUEST_NETWORK}="wifi-iface"
  uci set wireless.${GUEST_NETWORK}.device="${WIFI_DEV}"
  uci set wireless.${GUEST_NETWORK}.mode="ap"
  uci set wireless.${GUEST_NETWORK}.network="${GUEST_NETWORK}"
  uci set wireless.${GUEST_NETWORK}.ssid="${GUEST_SSID}"
  uci set wireless.${GUEST_NETWORK}.encryption="psk2"
  uci set wireless.${GUEST_NETWORK}.key="burghalde"
  uci commit wireless
  wifi reload
}

function configureDHCP()  
{
  # Configure DHCP
  uci -q delete dhcp.${GUEST_NETWORK}
  uci set dhcp.${GUEST_NETWORK}="dhcp"
  uci set dhcp.${GUEST_NETWORK}.interface="${GUEST_NETWORK}"
  uci set dhcp.${GUEST_NETWORK}.start="100"
  uci set dhcp.${GUEST_NETWORK}.limit="150"
  uci set dhcp.${GUEST_NETWORK}.leasetime="1h"
  uci set dhcp.${GUEST_NETWORK}.netmask="255.255.255.0"
  uci commit dhcp
  /etc/init.d/dnsmasq restart
}

function configureFirewall() {
  # Configure firewall
  uci -q delete firewall.${GUEST_ZONE}
  uci set firewall.${GUEST_ZONE}="zone"
  uci set firewall.${GUEST_ZONE}.name="${GUEST_ZONE}"
  uci set firewall.${GUEST_ZONE}.network="${GUEST_NETWORK}"
  uci set firewall.${GUEST_ZONE}.input="REJECT"
  uci set firewall.${GUEST_ZONE}.output="ACCEPT"
  uci set firewall.${GUEST_ZONE}.forward="REJECT"
  uci -q delete firewall.${GUEST_ZONE}_wan
  uci set firewall.${GUEST_ZONE}_wan="forwarding"
  uci set firewall.${GUEST_ZONE}_wan.src="${GUEST_NETWORK}"
  uci set firewall.${GUEST_ZONE}_wan.dest="wan"
  uci -q delete firewall.${GUEST_ZONE}_dns
  uci set firewall.${GUEST_ZONE}_dns="rule"
  uci set firewall.${GUEST_ZONE}_dns.name="Allow-DNS-Guest"
  uci set firewall.${GUEST_ZONE}_dns.src="${GUEST_NETWORK}"
  uci set firewall.${GUEST_ZONE}_dns.dest_port="53"
  uci set firewall.${GUEST_ZONE}_dns.proto="tcp udp"
  uci set firewall.${GUEST_ZONE}_dns.target="ACCEPT"
  uci -q delete firewall.${GUEST_ZONE}_dhcp
  uci set firewall.${GUEST_ZONE}_dhcp="rule"
  uci set firewall.${GUEST_ZONE}_dhcp.name="Allow-DHCP-Guest"
  uci set firewall.${GUEST_ZONE}_dhcp.src="${GUEST_NETWORK}"
  uci set firewall.${GUEST_ZONE}_dhcp.src_port="68"
  uci set firewall.${GUEST_ZONE}_dhcp.dest_port="67"
  uci set firewall.${GUEST_ZONE}_dhcp.proto="udp"
  uci set firewall.${GUEST_ZONE}_dhcp.family="ipv4"
  uci set firewall.${GUEST_ZONE}_dhcp.target="ACCEPT"
  uci commit firewall
  /etc/init.d/firewall restart
}

function dumpConfig() {
   SUFFIX=$(date '+%Y%m%d_%H%M%S')
   if [ ! -z "${1}" ]; then
      SUFFIX=${1}
   fi   
   cp /etc/config/network /root/etc_config_network.${SUFFIX}
   uci show network > /root/uci_show_network.${SUFFIX}
   cp /etc/config/wireless /root/etc_config_wireless.${SUFFIX}
   uci show wireless > /root/uci_show_wireless.${SUFFIX}
   cp /etc/config/dhcp /root/etc_config_dhcp.${SUFFIX}
   uci show dhcp > /root/uci_show_dhcp.${SUFFIX}
}

deleteAll() {
  uci -q delete dhcp.${GUEST_NETWORK}
  uci commit dhcp
  /etc/init.d/dnsmasq restart
  uci -q delete wireless.${GUEST_NETWORK}
  uci commit wireless
  wifi reload
  uci -q delete network.${GUEST_NETWORK}
  uci -q delete network.${GUEST_DEV}
  uci commit network
  /etc/init.d/network restart
}

# main
GUEST_DEV="gastdev"
GUEST_NETWORK="gastnw"
GUEST_BRIDGE="br-gast"
GUEST_ZONE="gastzone"
GUEST_SSID="ZINKS_GAST_2"
    
configureNetwork
configureWireless
configureDHCP
#deleteAll
dumpConfig

# keep last line due to bug in vi on openwrt

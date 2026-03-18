
1. Neues Netzwerk erstellen ipv6_enabled
  podman network create --ipv6 dual-stack
2. stoppe folgende services
  * home-assistant
  * zigbee2mqtt
  * influxdb
  * matter-server
3. /etc/containers/systemd/XXX.container network auf dual-stack ändern für folgende services:
  * home-assistant
  * zigbee2mqtt
  * influxdb
  * matter-server
4. systemctl daemon-reload  
5. services neu starten

zigbee2mqtt.container
home-assistant.container
influx-db.container
matter-server.container
jellyfin.container
grafana.container

caddy.container    
vaultwarden.container
immich-postgres.container
immich-server.container
immich-machine-learning.container
immich-redis.container
nextcloud-app.container
nextcloud.pod
nextcloud-db.container
nextcloud-redis.container

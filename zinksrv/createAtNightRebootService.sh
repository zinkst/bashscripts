#!/bin/bash
cat << EOF > /etc/systemd/system/reboot-at-night.timer
[Unit]
Description=Reboot at night

[Timer]
Unit=reboot-at-night.service
OnCalendar=*-*-* 05:00:00

[Install]
WantedBy=basic.target
EOF

cat << EOF > /etc/systemd/system/reboot-at-night.service
[Unit]
Description=Reboots the server at night

[Service]
Type=simple
ExecStart=/usr/sbin/shutdown -r now
EOF

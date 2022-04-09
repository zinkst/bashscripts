#!/bin/bash
systemctl stop minidlna.service
su -s /bin/bash -c "minidlnad -R" minidlna
systemctl start minidlna.service
journalctl -fu minidlna.service
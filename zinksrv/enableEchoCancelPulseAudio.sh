#!/bin/sh
dnf install -y webrtc-audio-processing
cat <<EOF >> /etc/pulse/default.pa

# SZ added default echo sink see https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#Enable_Echo/Noise-Cancellation
.ifexists module-echo-cancel.so
load-module module-echo-cancel aec_method=webrtc source_name=echocancel_source sink_name=echocancel_sink
set-default-source echocancel_source
set-default-sink echocancel_sink
.endif
EOF
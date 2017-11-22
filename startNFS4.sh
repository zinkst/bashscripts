iptables -A INPUT -m tcp -p tcp --dport 2049 -j ACCEPT
service nfs start

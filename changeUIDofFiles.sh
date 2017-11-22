    
/usr/sbin/usermod -u 1000 zinks
#find files they use to own and give them ownership again
echo "Changing all files owned by $myname to the new id... (this may take awhile)"
find /data/home/home_oc2 -uid 500 -exec chown -h zinks {} \;

function removeKeystoneV2_Endpoint () {
    echo "removing V2 Endpoints with openstack client"
    #source ${HOME}/openrc
    #openstack endpoint list
    #openstack endpoint list | grep identity | grep v2.0 | awk '{ print $2 }' > /tmp/ep-list.txt
    echo 1 > /tmp/ep-list.txt
    echo 2 >> /tmp/ep-list.txt
    echo 3 >> /tmp/ep-list.txt
    while read V2_ENDPOINT_ID; do  
        echo "deleting endpoint ${V2_ENDPOINT_ID}"
        #openstack endpoint delete ${V2_ENDPOINT_ID};
		done  < /tmp/ep-list.txt
} 

removeKeystoneV2_Endpoint

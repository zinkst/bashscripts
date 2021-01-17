#!/bin/bash
ibm-notes8-zap
ls -l /tmp/notes* /tmp/Notes_socket_* /tmp/.com_ibm_tools_attach /tmp/stpe* /tmp/OSL_PIPE* /tmp/cache_1000 /tmp/lnotesMutex*
rm -rf /tmp/notes* /tmp/Notes_socket_* /tmp/.com_ibm_tools_attach /tmp/stpe* /tmp/OSL_PIPE* /tmp/cache_1000 /tmp/lnotesMutex*
sudo service ipm-confidential stop
sudo service cups stop

#sudo service ipm-confidential start
#sudo service cups start

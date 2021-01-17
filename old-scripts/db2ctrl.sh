INSTANCE_USER="db2inst1"
if [ ! -z ${1} ]
then 
  if [ ${1} = "stop" ] 
  then
    echo "stopping db2 instance "${INSTANCE_USER} 
    su - ${INSTANCE_USER} -c"db2stop" 
  fi
else
  echo "starting db2 instance "${INSTANCE_USER} 
  su - ${INSTANCE_USER} -c"db2start"
fi;


#su - db2as -c"db2admin start"
#su - db2as -c"db2admin stop"

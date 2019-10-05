#echo "/links/bin/$(hostname -s)"
if [ -d /links/bin/$(hostname -s) ]; 
then
  if ! [[ $PATH =~ "/links/bin/$(hostname -s)" ]]
  then
    #echo "export PATH=${PATH}:/links/bin/$(hostname -s)"
    export PATH=${PATH}:/links/bin/$(hostname -s):/links/bin
  fi
fi  

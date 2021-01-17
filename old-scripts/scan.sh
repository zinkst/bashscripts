#!/bin/bash

export JAVA_HOME=/opt/IBM/WebSphere/AppServer/java
export PATH=$PATH:$JAVA_HOME/bin

SEARCHPATHS[1]="opt"
SEARCHPATHS[2]="home"
SEARCHPATHS[3]="var"
SEARCHPATHS[4]="tmp"

index="1 2 3 4"
for ind in $index
do
    echo "scanning: /${SEARCHPATHS[ind]}  logfile: ${SEARCHPATHS[ind]}.log"
    java GrepJar actuate_files 	"/${SEARCHPATHS[ind]}" | tee -a "${SEARCHPATHS[ind]}.log"
done    
    

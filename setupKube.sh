#!/bin/bash

function installMinikube () {
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64  && sudo install minikube-linux-amd64 /usr/local/bin/minikube
}  

function installHelm () {
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
    chmod 700 get_helm.sh
    ./get_helm.sh
}

function installConcourseMinikube() {
  helm init
  helm upgrade -i stable/concourse
}

function configureMinikube() {
  # minikube on Docker
  # sudo chgrp -R $USER $HOME/.kube
  # sudo chgrp -R users $HOME/.kube
  # sudo chown -R $USER $HOME/.minikube
  # sudo chgrp -R users $HOME/.minikube
  # export CHANGE_MINIKUBE_NONE_USER=true; sudo -E minikube start --vm-driver=none
  minikube start --memory 4096 --cpu=4
} 

function startConcourseMinikube() {
    #sudo -E systemctl start docker
    #sudo -E minikube start 
    if [ $(minikube status --format {{.MinikubeStatus}}) == "Stopped" ];
    then 
      echo "Starting minikube" 
      minikube start
      echo "waiting 300 secs ... "
      sleep 300
    fi  
    kubectl get pods --all-namespaces
    export POD_NAME=$(kubectl get pods --namespace default -l "app=iron-fox-web" -o jsonpath="{.items[0].metadata.name}") &&  $(kubectl port-forward --namespace default $POD_NAME 8080:8080) 2>&1 /dev/null &
    #fly -t cc-minik login --concourse-url http://127.0.0.1:8080/ 
    fly -t cc-minik login
}


#installMinikube
#installHelm
#installConcourseMinikube
startConcourseMinikube


 

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://github.com/yosoyvilla/k8s-demo
echo "===============================deploy voting app==========================================================="

git clone https://github.com/yosoyvilla/k8s-demo.git && cd k8s-demo
kubectl create namespace vote
kubectl create -f deployments/
kubectl create -f services/
minikube addons enable ingress
kubectl apply -f demo-ingress.yaml
kubectl --namespace=vote get ingress

# Add the following line to the bottom of the /etc/hosts file 
# <your-address> demo-kubernetes.info



#Deploy the sample application
kubectl get service --all-namespaces #list all services in all namespace
kubectl get services #The application will start. As each pod becomes ready, the Istio sidecar will deploy along with it.
kubectl get pods

for i in {1..60}; do # Timeout after 5 minutes, 60x5=300 secs, 3 mins
    if kubectl get pods --namespace=vote |grep ContainerCreating ; then
      sleep 5
    else
        break
    fi
done

kubectl get service --all-namespaces #list all services in all namespace
# Verify your installation
kubectl get pod -n vote

kubectl delete namespace vote
#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://chaos-mesh.org/docs/installation/get_started_on_kind/
echo "===============================Install Chaos Mesh==========================================================="

/bin/sh -c 'curl -sSL https://raw.githubusercontent.com/chaos-mesh/chaos-mesh/master/install.sh | bash -s -- --local kind' 
# curl -sSL https://raw.githubusercontent.com/chaos-mesh/chaos-mesh/master/install.sh | bash -s -- --local kind


#Deploy the sample application
kubectl get service --all-namespaces #list all services in all namespace
kubectl get services #The application will start. As each pod becomes ready, the Istio sidecar will deploy along with it.
kubectl get pods

for i in {1..60}; do # Timeout after 5 minutes, 60x2=120 secs, 2 mins
    if kubectl get pods --namespace=chaos-testing |grep Running ; then
      break
    fi
    sleep 2
done

kubectl get service --all-namespaces #list all services in all namespace
# Verify your installation
kubectl get pod -n chaos-testing

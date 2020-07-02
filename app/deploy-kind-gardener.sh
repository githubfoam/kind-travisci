#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

#https://istio.io/docs/setup/platform-setup/gardener/
#https://github.com/gardener/gardener/blob/master/docs/development/local_setup.md
echo "=============================Weave Scope============================================================="
- curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
- chmod +x ./kind
- sudo mv ./kind /usr/local/bin/kind
- kind get clusters #see the list of kind clusters
- kind create cluster --name istio-testing #Create a cluster,By default, the cluster will be given the name kind
- kind get clusters
- sudo snap install kubectl --classic
- kubectl config get-contexts #list the local Kubernetes contexts
- kubectl config use-context kind-istio-testing #run following command to set the current context for kubectl
- kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml #deploy Dashboard
- echo "===============================Waiting for Dashboard to be ready==========================================================="
- |
  for i in {1..150}; do # Timeout after 5 minutes, 150x2=300 secs
    if kubectl get pods --namespace=kubernetes-dashboard | grep Running ; then
      break
    fi
    sleep 2
  done
- kubectl get pod -n kubernetes-dashboard #Verify that Dashboard is deployed and running
- kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default #Create a ClusterRoleBinding to provide admin access to the newly created cluster
#To login to Dashboard, you need a Bearer Token. Use the following command to store the token in a variable
- token=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
- echo $token #Display the token using the echo command and copy it to use for logging into Dashboard.
- kubectl proxy & # Access Dashboard using the kubectl command-line tool by running the following command, Starting to serve on 127.0.0.1:8001
- |
  for i in {1..60}; do # Timeout after 1 mins, 60x1=60 secs
    if nc -z -v 127.0.0.1 8001 2>&1 | grep succeeded ; then
      break
    fi
    sleep 1
  done
# - kind delete cluster --name istio-testing #delete the existing cluster

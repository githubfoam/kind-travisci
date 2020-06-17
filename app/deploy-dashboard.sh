#!/bin/bash


echo "=============================Dashboard============================================================="
kind create cluster --name dashboard-testing
kubectl config use-context kind-dashboard-testing
kubectl cluster-info
kubectl get pods --all-namespaces;
kubectl get pods -n default;
kubectl get pod -o wide #The IP column will contain the internal cluster IP address for each pod.
kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces
export DASHBOARDVERSION="2.0.0-beta8"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v$DASHBOARDVERSION/aio/deploy/recommended.yaml #deploy Dashboard
kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces-
kubectl get pods -n openebs -l openebs.io/component-name=openebs-localpv-provisioner #Observe localhost provisioner pod
kubectl get sc #Check the storage Class

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
# - kind delete cluster --name istio-testing #delete the existing cluster

kubectl get pods --all-namespaces
kubectl get pods --namespace=openebs
kubectl get pod -n default -o wide  --all-namespaces
kind delete cluster --name dashboard-testing
echo "=============================Dashboard============================================================="

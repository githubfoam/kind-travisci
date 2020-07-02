#!/bin/bash
# openesb component list
#https://github.com/openebs/openebs/blob/master/k8s/openebs-operator.yaml

echo "=============================openEBS============================================================="
# kind create cluster --name openesb-testing
# kubectl config use-context kind-openesb-testing
kubectl cluster-info
kubectl get pods --all-namespaces
kubectl get pods -n default
kubectl get pod -o wide #The IP column will contain the internal cluster IP address for each pod.
kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces
kubectl apply -f https://openebs.github.io/charts/openebs-operator.yaml #install OpenEBS
kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces-
kubectl get pods -n openebs -l openebs.io/component-name=openebs-localpv-provisioner #Observe localhost provisioner pod
kubectl get sc #Check the storage Class
echo echo "Waiting for openebs-localpv-provisioner component to be ready ..."
for i in {1..60}; do # Timeout after 5 minutes, 150x5=300 secs
      if kubectl get pods --namespace=openebs -l openebs.io/component-name=openebs-localpv-provisioner | grep Running ; then
        break
      fi
      sleep 5
done
echo echo "Waiting for maya-apiserver component to be ready ..."
for i in {1..60}; do # Timeout after 5 minutes, 150x5=300 secs
      if kubectl get pods --namespace=openebs -l openebs.io/component-name=maya-apiserver | grep Running ; then
        break
      fi
      sleep 5
done
echo echo "Waiting for openebs-ndm component to be ready ..."
for i in {1..60}; do # Timeout after 5 minutes, 150x5=300 secs
      if kubectl get pods --namespace=openebs -l openebs.io/component-name=openebs-ndm | grep Running ; then
        break
      fi
      sleep 5
done
echo echo "Waiting for openebs-ndm-operator component to be ready ..."
for i in {1..60}; do # Timeout after 5 minutes, 150x5=300 secs
      if kubectl get pods --namespace=openebs -l openebs.io/component-name=openebs-ndm-operator | grep Running ; then
        break
      fi
      sleep 5
done
echo "Waiting for openesb to be ready ..."
  for i in {1..60}; do # Timeout after 2 minutes, 60x2=300 secs
      if kubectl get pods --namespace=openebs | grep Running ; then
        break
      fi
      sleep 5
done
kubectl get pods --all-namespaces
kubectl get pods --namespace=openebs
kubectl get pod -n default -o wide  --all-namespaces
# kind delete cluster --name openesb-testing
echo "=============================openEBS============================================================="

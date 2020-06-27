#!/bin/bash
#https://istio.io/docs/setup/platform-setup/kind/
#https://kind.sigs.k8s.io/docs/user/quick-start/
#https://istio.io/docs/setup/getting-started/

echo "=============================cilium============================================================="
# Download the Cilium release tarball and change to the kubernetes install directory
curl -LO https://github.com/cilium/cilium/archive/master.tar.gz
tar xzvf master.tar.gz && cd cilium-master/install/kubernetes

#Preload the cilium image into each worker node in the kind cluster
docker pull cilium/cilium:latest
kind load docker-image cilium/cilium:latest

#Install Cilium release via Helm
helm install cilium ./cilium \
   --namespace kube-system \
   --set global.nodeinit.enabled=true \
   --set global.kubeProxyReplacement=partial \
   --set global.hostServices.enabled=false \
   --set global.externalIPs.enabled=true \
   --set global.nodePort.enabled=true \
   --set global.hostPort.enabled=true \
   --set global.pullPolicy=IfNotPresent \
   --set config.ipam=kubernetes

echo echo "Waiting for cilium to be ready ..."
for i in {1..60}; do # Timeout after 3 minutes, 60x5=300 secs
     if kubectl get pods --namespace=kube-system  | grep ContainerCreating ; then
         sleep 5
     else
         break
     fi
done

#kubectl -n kube-system get pods --watch # interactive shell

#deploy the “connectivity-check” to test connectivity between pods.
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/kubernetes/connectivity-check/connectivity-check.yaml
# Specify the namespace in which Cilium is installed as CILIUM_NAMESPACE environment variable
export CILIUM_NAMESPACE=kube-system

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

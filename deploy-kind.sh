#!/bin/bash
echo "=============================deploy kind============================================================="
docker version
export KIND_VERSION="0.8.1"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v$KIND_VERSION/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind
kind get clusters #see the list of kind clusters
kind get clusters
kubectl config get-contexts #kind is prefixed to the context and cluster names, for example: kind-istio-testing
echo "=============================deploy kind============================================================="

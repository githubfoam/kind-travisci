#!/bin/bash
# openesb component list
#https://github.com/openebs/openebs/blob/master/k8s/openebs-operator.yaml

echo "=============================deploy kind============================================================="
- docker version
- curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
- chmod +x ./kind
- mv ./kind /usr/local/bin/kind
- kind get clusters #see the list of kind clusters
- kind get clusters
- kubectl config get-contexts #kind is prefixed to the context and cluster names, for example: kind-istio-testing
echo "=============================deploy kind============================================================="

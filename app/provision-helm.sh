#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script


echo fetch and install helm...
HELM_ARCHIVE=helm-v2.12.1-linux-amd64.tar.gz
HELM_DIR=linux-amd64
HELM_BIN=$HELM_DIR/helm
curl -LsO https://storage.googleapis.com/kubernetes-helm/$HELM_ARCHIVE && tar -zxvf $HELM_ARCHIVE && chmod +x $HELM_BIN && cp $HELM_BIN /usr/local/bin
rm $HELM_ARCHIVE
rm -rf $HELM_DIR

helm version

echo setup tiller account...
kubectl -n kube-system create sa tiller && kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller

echo initialize tiller...
helm init --wait --skip-refresh --upgrade --service-account tiller
echo tiller initialized
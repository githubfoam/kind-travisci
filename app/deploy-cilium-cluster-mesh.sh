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

#enabling managed etcd
#setting both cluster-name and cluster-id for each cluster
#Make sure context is set to kind-cluster2 cluster
kubectl config use-context kind-cluster2

#Install Cilium release via Helm
helm install cilium ./cilium \
   --namespace kube-system \
   --set global.nodeinit.enabled=true \
   --set global.kubeProxyReplacement=partial \
   --set global.hostServices.enabled=false \
   --set global.externalIPs.enabled=true \
   --set global.nodePort.enabled=true \
   --set global.hostPort.enabled=true \
   --set global.etcd.enabled=true \
   --set global.etcd.managed=true \
   --set global.identityAllocationMode=kvstore \
   --set global.cluster.name=cluster2 \
   --set global.cluster.id=2

#Change the kubectl context to kind-cluster1 cluster
kubectl config use-context kind-cluster1

helm install cilium ./cilium \
   --namespace kube-system \
   --set global.nodeinit.enabled=true \
   --set global.kubeProxyReplacement=partial \
   --set global.hostServices.enabled=false \
   --set global.externalIPs.enabled=true \
   --set global.nodePort.enabled=true \
   --set global.hostPort.enabled=true \
   --set global.etcd.enabled=true \
   --set global.etcd.managed=true \
   --set global.identityAllocationMode=kvstore \
   --set global.cluster.name=cluster1 \
   --set global.cluster.id=1



echo echo "Waiting for cilium to be ready ..."
for i in {1..60}; do # Timeout after 3 minutes, 60x5=300 secs
     if kubectl get pods --namespace=kube-system  | grep ContainerCreating ; then
         sleep 5
     else
         break
     fi
done

#Expose the Cilium etcd to other clusters
#For Kind, deploy the NodePort service into the kube-system namespace.
#https://docs.cilium.io/en/latest/gettingstarted/clustermesh/#gs-clustermesh-expose-etcd
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/kubernetes/clustermesh/cilium-etcd-external-service/cilium-etcd-external-nodeport.yaml

#Extract the TLS keys and generate the etcd configuration
# Clone the cilium/clustermesh-tools repository
# contains scripts to extracts the secrets and generate a Kubernetes secret in form of a YAML file
#Ensure that the kubectl context is pointing to the cluster you want to extract the secret from
git clone https://github.com/cilium/clustermesh-tools.git && cd clustermesh-tools

#Extract the TLS certificate, key and root CA authority.
#extract the keys that Cilium is using to connect to the etcd in the local cluster. 
#The key files are written to config/<cluster-name>.*.{key|crt|-ca.crt}
# ./extract-etcd-secrets.sh
bash extract-etcd-secrets.sh

#kubectl -n kube-system get pods --watch # interactive shell

#deploy the “connectivity-check” to test connectivity between pods.
kubectl apply -f https://raw.githubusercontent.com/cilium/cilium/HEAD/examples/kubernetes/connectivity-check/connectivity-check.yaml
# Specify the namespace in which Cilium is installed as CILIUM_NAMESPACE environment variable
export CILIUM_NAMESPACE=kube-system

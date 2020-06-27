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

echo "=============================Hubble distributed mode (beta)============================================================="
# distributed mode (beta)
helm upgrade cilium ./cilium \
   --namespace $CILIUM_NAMESPACE \
   --reuse-values \
   --set global.hubble.enabled=true \
   --set global.hubble.listenAddress=":4244" \
   --set global.hubble.metrics.enabled="{dns,drop,tcp,flow,port-distribution,icmp,http}" \
   --set global.hubble.relay.enabled=true \
   --set global.hubble.ui.enabled=true


# Restart the Cilium daemonset to allow Cilium agent to pick up the ConfigMap changes
kubectl rollout restart -n $CILIUM_NAMESPACE ds/cilium
# pick one Cilium instance and validate that Hubble is properly configured to listen on a UNIX domain socket
kubectl exec -n $CILIUM_NAMESPACE -t ds/cilium -- hubble observe

kubectl get pods --all-namespaces
kubectl get pods -n $CILIUM_NAMESPACE
kubectl get pod -o wide #The IP column will contain the internal cluster IP address for each pod.
echo echo "Waiting for cilium to be ready ..."
for i in {1..60}; do # Timeout after 3 minutes, 60x5=300 secs
     if kubectl get pods --namespace=$CILIUM_NAMESPACE  | grep ContainerCreating ; then
         sleep 5
     else
         break
     fi
done
kubectl get pods --all-namespaces
kubectl get pods -n $CILIUM_NAMESPACE
kubectl get pod -o wide #The IP column will contain the internal cluster IP address for each pod.

# validate that Hubble Relay is running, install the hubble CLI
export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
curl -LO "https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-amd64.tar.gz"
curl -LO "https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-amd64.tar.gz.sha256sum"
sha256sum --check hubble-linux-amd64.tar.gz.sha256sum
# move the hubble CLI to a directory listed in the $PATH environment variable
tar zxf hubble-linux-amd64.tar.gz &&  mv hubble /usr/local/bin

#set up a port forwarding for hubble-relay service and run hubble observe command
kubectl port-forward -n $CILIUM_NAMESPACE svc/hubble-relay 4245:80 &
hubble observe --server localhost:4245
#set and export the HUBBLE_DEFAULT_SOCKET_PATH environment variable
#use hubble status and hubble observe commands without having to specify the server address via the --server flag
export HUBBLE_DEFAULT_SOCKET_PATH=localhost:4245
#validate that Hubble UI is properly configured, set up a port forwarding for hubble-ui service
kubectl port-forward -n $CILIUM_NAMESPACE svc/hubble-ui 12000:80 &
curl http://localhost:12000

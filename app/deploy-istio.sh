#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

#https://kind.sigs.k8s.io/docs/user/quick-start/
#https://istio.io/docs/setup/platform-setup/kind/
echo "=============================kind istio============================================================="
docker version
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.8.1/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind get clusters #see the list of kind clusters
kind create cluster --name istio-testing #Create a cluster,By default, the cluster will be given the name kind
kind get clusters
# - sudo snap install kubectl --classic
kubectl config get-contexts #list the local Kubernetes contexts
kubectl config use-context kind-istio-testing #run following command to set the current context for kubectl

#https://istio.io/latest/docs/setup/getting-started/
echo "===============================Install istio==========================================================="
#Download Istio
#/bin/sh -c 'curl -L https://istio.io/downloadIstio | sh -' #download and extract the latest release automatically (Linux or macOS)
export ISTIOVERSION="1.6.4"
/bin/sh -c 'curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIOVERSION sh -' #download a specific version

cd istio-* #Move to the Istio package directory. For example, if the package is istio-1.6.0
export PATH=$PWD/bin:$PATH #Add the istioctl client to your path, The istioctl client binary in the bin/ directory.
#precheck inspects a Kubernetes cluster for Istio install requirements
istioctl experimental precheck #https://istio.io/docs/reference/commands/istioctl/#istioctl-experimental-precheck
istioctl version
istioctl manifest apply --set profile=demo #Install Istio, use the demo configuration profile
kubectl label namespace default istio-injection=enabled #Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later

#Deploy the sample application
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml #Deploy the Bookinfo sample application:
kubectl get service --all-namespaces #list all services in all namespace
kubectl get services #The application will start. As each pod becomes ready, the Istio sidecar will deploy along with it.
kubectl get pods
for i in {1..60}; do # Timeout after 5 minutes, 60x2=120 secs, 2 mins
    if kubectl get pods --namespace=istio-system |grep Running ; then
      break
    fi
    sleep 2
done
kubectl get service --all-namespaces #list all services in all namespace

# see if the app is running inside the cluster and serving HTML pages by checking for the page title in the response
#error: unable to upgrade connection: container not found ("ratings")
#kubectl exec $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
#interactive shell
#kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
# - |
#   kubectl exec -it $(kubectl get pod \
#                -l app=ratings \
#                -o jsonpath='{.items[0].metadata.name}') \
#                -c ratings \
#                -- curl productpage:9080/productpage | grep -o "<title>.*</title>" <title>Simple Bookstore App</title>


#Open the application to outside traffic
#The Bookinfo application is deployed but not accessible from the outside. To make it accessible, you need to create an Istio Ingress Gateway, which maps a path to a route at the edge of your mesh.
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml #Associate this application with the Istio gateway
istioctl analyze #Ensure that there are no issues with the configuration

#Other platforms
#Determining the ingress IP and ports
#If the EXTERNAL-IP value is set, your environment has an external load balancer that you can use for the ingress gateway.
#If the EXTERNAL-IP value is <none> (or perpetually <pending>), your environment does not provide an external load balancer for the ingress gateway.
#access the gateway using the service’s node port.
kubectl get svc istio-ingressgateway -n istio-system #determine if your Kubernetes cluster is running in an environment that supports external load balancers

#external load balancer
# #Follow these instructions if you have determined that your environment has an external load balancer.
# # If the EXTERNAL-IP value is <none> (or perpetually <pending>), your environment does not provide an external load balancer for the ingress gateway,access the gateway using the service’s node port.
# - export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# - export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
# - export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')

# #In certain environments, the load balancer may be exposed using a host name, instead of an IP address.
# #the ingress gateway’s EXTERNAL-IP value will not be an IP address, but rather a host name

#failed to set the INGRESS_HOST environment variable, correct the INGRESS_HOST value
 export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

#Follow these instructions if your environment does not have an external load balancer and choose a node port instead
#Set the ingress ports:
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}') #Set the ingress ports
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}') #Set the ingress ports

#INGRESS_HOST: unbound variable
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT #Set GATEWAY_URL
# echo $GATEWAY_URL #Ensure an IP address and port were successfully assigned to the environment variable
# echo http://$GATEWAY_URL/productpage #Verify external access,retrieve the external address of the Bookinfo application
# echo $(curl http://$GATEWAY_URL/productpage)

#View the dashboard
#istioctl dashboard kiali #optional dashboards installed by the demo installation,Access the Kiali dashboard. The default user name is admin and default password is admin
#istioctl dashboard kiali # interactive shell


#Uninstall
#Cleanup #https://istio.io/latest/docs/examples/bookinfo/#cleanup
#Delete the routing rules and terminate the application pods
samples/bookinfo/platform/kube/cleanup.sh
#Confirm shutdown
kubectl get virtualservices   #-- there should be no virtual services
kubectl get destinationrules  #-- there should be no destination rules
kubectl get gateway           #-- there should be no gateway
kubectl get pods              #-- the Bookinfo pods should be deleted


# #The Istio uninstall deletes the RBAC permissions and all resources hierarchically under the istio-system namespace
# #It is safe to ignore errors for non-existent resources because they may have been deleted hierarchically.
/bin/sh -eu -xv -c 'istioctl manifest generate --set profile=demo | kubectl delete -f -'
#The istio-system namespace is not removed by default.
#If no longer needed, use the following command to remove it
 kubectl delete namespace istio-system


# - |
#   SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#   # only ask if in interactive mode
#   if [[ -t 0 && -z ${NAMESPACE} ]];then
#     echo -n "namespace ? [default] "
#     read -r NAMESPACE
#   fi
#   if [[ -z ${NAMESPACE} ]];then
#     NAMESPACE=default
#   fi
#   echo "using NAMESPACE=${NAMESPACE}"
#   protos=( destinationrules virtualservices gateways )
#   for proto in "${protos[@]}"; do
#     for resource in $(kubectl get -n ${NAMESPACE} "$proto" -o name); do
#       kubectl delete -n ${NAMESPACE} "$resource";
#     done
#   done
#   OUTPUT=$(mktemp)
#   export OUTPUT
#   echo "Application cleanup may take up to one minute"
#   kubectl delete -n ${NAMESPACE} -f "$SCRIPTDIR/bookinfo.yaml" > "${OUTPUT}" 2>&1
#   ret=$?
#   function cleanup() {
#     rm -f "${OUTPUT}"
#   }
#   trap cleanup EXIT
#   if [[ ${ret} -eq 0 ]];then
#     cat "${OUTPUT}"
#   else
#     # ignore NotFound errors
#     OUT2=$(grep -v NotFound "${OUTPUT}")
#     if [[ -n ${OUT2} ]];then
#       cat "${OUTPUT}"
#       exit ${ret}
#     fi
#   fi

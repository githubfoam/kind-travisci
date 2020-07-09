#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

#https://istio.io/latest/docs/examples/microservices-istio/

#https://istio.io/latest/docs/examples/microservices-istio/setup-kubernetes-cluster/
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


# Setup a Kubernetes Cluster

# Create an environment variable to store the name of a namespace
export NAMESPACE=tutorial
# Create the namespace
kubectl create namespace $NAMESPACE

#https://istio.io/latest/docs/setup/getting-started/
# https://istio.io/latest/docs/examples/microservices-istio/setup-kubernetes-cluster/
# Install Istio using the demo profile.
echo "===============================Install istio==========================================================="
#Download Istio
#/bin/sh -c 'curl -L https://istio.io/downloadIstio | sh -' #download and extract the latest release automatically (Linux or macOS)
export ISTIORELEASE="1.6"
export ISTIOVERSION="1.6.4"
/bin/sh -c 'curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIOVERSION sh -' #download a specific version

cd istio-* #Move to the Istio package directory. For example, if the package is istio-1.6.0
export PATH=$PWD/bin:$PATH #Add the istioctl client to your path, The istioctl client binary in the bin/ directory.
#precheck inspects a Kubernetes cluster for Istio install requirements
istioctl experimental precheck #https://istio.io/docs/reference/commands/istioctl/#istioctl-experimental-precheck
istioctl version
#Install Istio, use the demo configuration profile
istioctl manifest apply --set profile=demo

#Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies when you deploy your application later
kubectl label namespace default istio-injection=enabled

# #Deploy the sample application
# kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml #Deploy the Bookinfo sample application:
# kubectl get service --all-namespaces #list all services in all namespace
# kubectl get services #The application will start. As each pod becomes ready, the Istio sidecar will deploy along with it.
# kubectl get pods
# for i in {1..60}; do # Timeout after 5 minutes, 60x2=120 secs, 2 mins
#     if kubectl get pods --namespace=istio-system |grep Running ; then
#       break
#     fi
#     sleep 2
# done
# kubectl get service --all-namespaces #list all services in all namespace
#
# # see if the app is running inside the cluster and serving HTML pages by checking for the page title in the response
# #error: unable to upgrade connection: container not found ("ratings")
# #kubectl exec $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
# #interactive shell
# #kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"
# # - |
# #   kubectl exec -it $(kubectl get pod \
# #                -l app=ratings \
# #                -o jsonpath='{.items[0].metadata.name}') \
# #                -c ratings \
# #                -- curl productpage:9080/productpage | grep -o "<title>.*</title>" <title>Simple Bookstore App</title>
#
#
# #Open the application to outside traffic
# #The Bookinfo application is deployed but not accessible from the outside. To make it accessible, you need to create an Istio Ingress Gateway, which maps a path to a route at the edge of your mesh.
# kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml #Associate this application with the Istio gateway
# istioctl analyze #Ensure that there are no issues with the configuration
#
# #Other platforms
# #Determining the ingress IP and ports
# #If the EXTERNAL-IP value is set, your environment has an external load balancer that you can use for the ingress gateway.
# #If the EXTERNAL-IP value is <none> (or perpetually <pending>), your environment does not provide an external load balancer for the ingress gateway.
# #access the gateway using the service’s node port.
# kubectl get svc istio-ingressgateway -n istio-system #determine if your Kubernetes cluster is running in an environment that supports external load balancers
#
# #external load balancer
# # #Follow these instructions if you have determined that your environment has an external load balancer.
# # # If the EXTERNAL-IP value is <none> (or perpetually <pending>), your environment does not provide an external load balancer for the ingress gateway,access the gateway using the service’s node port.
# # - export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
# # - export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
# # - export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
#
# # #In certain environments, the load balancer may be exposed using a host name, instead of an IP address.
# # #the ingress gateway’s EXTERNAL-IP value will not be an IP address, but rather a host name
#
# #failed to set the INGRESS_HOST environment variable, correct the INGRESS_HOST value
#  export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
#
# #Follow these instructions if your environment does not have an external load balancer and choose a node port instead
# #Set the ingress ports:
# export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}') #Set the ingress ports
# export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}') #Set the ingress ports
#
# #INGRESS_HOST: unbound variable
# export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT #Set GATEWAY_URL
# # echo $GATEWAY_URL #Ensure an IP address and port were successfully assigned to the environment variable
# # echo http://$GATEWAY_URL/productpage #Verify external access,retrieve the external address of the Bookinfo application
# # echo $(curl http://$GATEWAY_URL/productpage)
#
# #View the dashboard
# #istioctl dashboard kiali #optional dashboards installed by the demo installation,Access the Kiali dashboard. The default user name is admin and default password is admin
# #istioctl dashboard kiali # interactive shell
#
# #Enable Envoy’s access logging.
# #https://istio.io/latest/docs/tasks/observability/logs/access-log/#before-you-begin
# #Deploy the sleep sample app to use as a test source for sending requests.
# kubectl apply -f samples/sleep/sleep.yaml


# enable Envoy’s access logging
# Skip the clean up and delete steps, because you need the sleep application
# https://istio.io/latest/docs/examples/microservices-istio/setup-kubernetes-cluster/
# https://istio.io/latest/docs/tasks/observability/logs/access-log/#before-you-begin
echo "===============================Enable Envoy’s access logging.==========================================================="
# Deploy the sleep sample app to use as a test source for sending requests.
# If you have automatic sidecar injection enabled, run the following command to deploy the sample app

# Otherwise, manually inject the sidecar before deploying the sleep application
# kubectl apply -f <(istioctl kube-inject -f samples/sleep/sleep.yaml)

kubectl apply -f samples/sleep/sleep.yaml
# kubectl apply -f https://github.com/istio/istio/tree/release-1.6/samples/sleep

# Set the SOURCE_POD environment variable to the name of your source pod:
export SOURCE_POD=$(kubectl get pod -l app=sleep -o jsonpath={.items..metadata.name})

# Start the httpbin sample.
# If you have enabled automatic sidecar injection, deploy the httpbin service

# Otherwise, you have to manually inject the sidecar before deploying the httpbin application
# kubectl apply -f <(istioctl kube-inject -f samples/httpbin/httpbin.yaml)

kubectl apply -f samples/httpbin/httpbin.yaml


# Enable Envoy’s access logging
# Install Istio using the demo profile.
# replace demo with the name of the profile you used when you installed Istio
istioctl install --set profile=demo --set meshConfig.accessLogFile="/dev/stdout"

# Test the access log
# connect to 10.110.95.100 port 8000 failed: Connection refused
# kubectl exec -it $(kubectl get pod -l app=sleep -o jsonpath='{.items[0].metadata.name}') -c sleep -- curl -v httpbin:8000/status/418

kubectl get pods --all-namespaces
echo echo "Waiting for sleep and httpbin to be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
      if kubectl get pods --namespace=default  | grep PodInitializing ; then
        sleep 10
      else
        break
      fi
done
echo echo "Waiting for kubernetes be ready ..."
for i in {1..150}; do # Timeout after 5 minutes, 60x5=300 secs
      if kubectl get pods --namespace=istio-system  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done
kubectl get pods --all-namespaces

# Check sleep’s log
kubectl logs -l app=sleep -c istio-proxy
# Check httpbin’s log
kubectl logs -l app=httpbin -c istio-proxy #2020-07-08T18:15:02.910663Z	info	Envoy proxy is ready


# https://istio.io/latest/docs/examples/microservices-istio/setup-kubernetes-cluster/
# Create a Kubernetes Ingress resource for these common Istio services using the kubectl
# Grafana
# Jaeger
# Prometheus
# Kiali
# The kubectl command can accept an in-line configuration to create the Ingress resources for each service
kubectl apply -f - <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: istio-system
  namespace: istio-system
spec:
  rules:
  - host: my-istio-dashboard.io
    http:
      paths:
      - path: /*
        backend:
          serviceName: grafana
          servicePort: 3000
  - host: my-istio-tracing.io
    http:
      paths:
      - path: /*
        backend:
          serviceName: tracing
          servicePort: 9411
  - host: my-istio-logs-database.io
    http:
      paths:
      - path: /*
        backend:
          serviceName: prometheus
          servicePort: 9090
  - host: my-kiali.io
    http:
      paths:
      - path: /*
        backend:
          serviceName: kiali
          servicePort: 20001
EOF


# Create a role to provide read access to the istio-system namespace.
# This role is required to limit permissions of the participants
kubectl apply -f - <<EOF
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: istio-system-access
  namespace: istio-system
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["get", "list"]
EOF

# Create a service account for each participant
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${NAMESPACE}-user
  namespace: $NAMESPACE
EOF


# Limit each participant’s permissions.
# participants only need to create resources in their namespace
# and to read resources from istio-system namespace
# avoid interfering with other namespaces in your cluster

# Create a role to allow read-write access to each participant’s namespace
# Bind the participant’s service account to this role
# and to the role for reading resources from istio-system
kubectl apply -f - <<EOF
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${NAMESPACE}-access
  namespace: $NAMESPACE
rules:
- apiGroups: ["", "extensions", "apps", "networking.k8s.io", "networking.istio.io", "authentication.istio.io",
              "rbac.istio.io", "config.istio.io"]
  resources: ["*"]
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${NAMESPACE}-access
  namespace: $NAMESPACE
subjects:
- kind: ServiceAccount
  name: ${NAMESPACE}-user
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${NAMESPACE}-access
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: ${NAMESPACE}-istio-system-access
  namespace: istio-system
subjects:
- kind: ServiceAccount
  name: ${NAMESPACE}-user
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: istio-system-access
EOF



# Each participant needs to use their own Kubernetes configuration file
# This configuration file specifies the cluster details, the service account, the credentials and the namespace of the participant

# Generate a Kubernetes configuration file for each participant
# This command assumes your cluster is named tutorial-cluster.
# If your cluster is named differently, replace all references with the name of your cluster.

# export NAMESPACE=tutorial, tutorial-user-config.yaml
echo $NAMESPACE

# Set the KUBECONFIG environment variable for the ${NAMESPACE}-user-config.yaml configuration file
# export KUBECONFIG=./${NAMESPACE}-user-config.yaml
export KUBECONFIG=${NAMESPACE}-user-config.yaml
# Verify that the configuration took effect by printing the current namespaces
# see the name of your namespace in the output
kubectl config view -o jsonpath="{.contexts[?(@.name==\"$(kubectl config current-context)\")].context.namespace}"



# Setup a Local Computer
# https://istio.io/latest/docs/examples/microservices-istio/setup-local-computer/
# verify istioctl
istioctl version


# Run a Microservice Locally
# https://istio.io/latest/docs/examples/microservices-istio/single/


# Download the service’s code and the package file into a separate directory
mkdir ratings && cd ratings
curl -s https://raw.githubusercontent.com/istio/istio/release-1.6/samples/bookinfo/src/ratings/ratings.js -o ratings.js
curl -s https://raw.githubusercontent.com/istio/istio/release-1.6/samples/bookinfo/src/ratings/package.json -o package.json


 # Install the dependencies of the ratings service in the same folder where you stored the service code and the package file
 npm install

# Run the service, passing 9080 as a parameter. The application then listens on port 9080
npm start 9080 &

# Open http://localhost:9080/ratings/7 in your browser
# curl localhost:9080/ratings/7


# Use the POST method of the curl command to set the ratings for the product to 1
curl -X POST localhost:9080/ratings/7 -d '{"Reviewer1":1,"Reviewer2":1}'

# Check the updated ratings
curl localhost:9080/ratings/7 &


# Run ratings in Docker
# how to package a single service into a container
# https://istio.io/latest/docs/examples/microservices-istio/package-service/


# Download the Dockerfile for the ratings microservice
curl -s https://raw.githubusercontent.com/istio/istio/release-1.6/samples/bookinfo/src/ratings/Dockerfile -o Dockerfile
# Observe the Dockerfile
cat Dockerfile
# Build a Docker image from the Dockerfile
# docker build -t $USER/ratings .
docker build -t . $USER/ratings

 # instructs Docker to expose port 9080 of the container to port 9081 of your computer,
 # allowing you to access the ratings microservice on port 9081.
docker run -d -p 9081:9080 $USER/ratings &

# Access http://localhost:9081/ratings/7 in your browser
# curl localhost:9081/ratings/7

# Observe the running container.
docker ps
# Stop the running containers
# docker stop <the container ID from the output of docker ps>



# Run Bookinfo with Kubernetes
# how to deploy the whole application to a Kubernetes cluster.
# https://istio.io/latest/docs/examples/microservices-istio/bookinfo-kubernetes/


# Deploy the application and a testing pod
# Set the MYHOST environment variable to hold the URL of the application
export MYHOST=$(kubectl config view -o jsonpath={.contexts..namespace}).bookinfo.com

# Deploy the application to your Kubernetes cluster
kubectl apply -l version!=v2,version!=v3 -f https://raw.githubusercontent.com/istio/istio/release-1.6/samples/bookinfo/platform/kube/bookinfo.yaml

# Check the status of the pods
kubectl get pods


# After the four services achieve the Running status, you can scale the deployment
# each version of each microservice run in three pods
kubectl scale deployments --all --replicas 3

# Check the status of the pods
kubectl get pods

# After the services achieve the Running status, deploy a testing pod, sleep, to use for sending requests to your microservices
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.6/samples/sleep/sleep.yaml

# confirm that the Bookinfo application is running, send a request to it with a curl command from your testing pod:
# interactive shell
# kubectl exec -it $(kubectl get pod -l app=sleep -o jsonpath='{.items[0].metadata.name}') -c sleep -- curl productpage:9080/productpage | grep -o "<title>.*</title>"


# Enable external access to the application

#!/bin/bash
# https://github.com/kubernetes/dashboard
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
# https://hub.helm.sh/charts/k8s-dashboard/kubernetes-dashboard
echo "=============================Dashboard============================================================="
kubectl cluster-info
kubectl get pods --all-namespaces
kubectl get pods -n default
kubectl get pod -o wide #The IP column will contain the internal cluster IP address for each pod.
kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces
# export DASHBOARDVERSION="2.0.0-beta8"
export DASHBOARDVERSION="2.0.1"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v$DASHBOARDVERSION/aio/deploy/recommended.yaml #deploy Dashboard
kubectl get service --all-namespaces # find a Service IP,list all services in all namespaces-
kubectl get sc #Check the storage Class
echo "===============================Waiting for dashboard to be ready==========================================================="
for i in {1..60}; do # Timeout after 5 minutes, 60x5=300 secs
    if kubectl get pods --namespace=kubernetes-dashboard | grep Running ; then
      break
    fi
    sleep 5
done
kubectl get pod -n kubernetes-dashboard #Verify that Dashboard is deployed and running
kubectl proxy & # Access Dashboard using the kubectl command-line tool by running the following command, Starting to serve on 127.0.0.1:8001
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
echo $(curl http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

#create sample user and log in
kubectl create clusterrolebinding default-admin --clusterrole cluster-admin --serviceaccount=default:default #Create a ClusterRoleBinding to provide admin access to the newly created cluster
#To login to Dashboard, you need a Bearer Token. Use the following command to store the token in a variable
export token=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)
echo $token #Display the token using the echo command and copy it to use for logging into Dashboard.

kubectl get pods --all-namespaces
kubectl get pod -n kubernetes-dashboard -o wide  --all-namespaces
echo "===============================Adding Heapster Metrics to the Kubernetes Dashboard==========================================================="
# - sudo snap install helm --classic && helm init
# - kubectl create serviceaccount --namespace kube-system tiller #Create a service account
# - kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller #Bind the new service account to the cluster-admin role. This will give tiller admin access to the entire cluster
# - kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}' #Deploy tiller and add the line serviceAccount: tiller to spec.template.spec
# - helm install --name heapster stable/heapster --namespace kube-system #install Heapster
# - kind delete cluster --name istio-testing #delete the existing cluster

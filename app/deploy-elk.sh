#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================ELK Elastic Kibana Logstash============================================================="

kubectl create namespace elk
kubectl apply --namespace=elk -f - <<"EOF"
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 2000Mi
      cpu: 2000m
    defaultRequest:
      memory: 1000Mi
      cpu: 1000m
    type: Container
EOF
echo "resource quotas applied to the namespace"

helm install --name elastic-stack --namespace=elk stable/elastic-stack -f my-elastic-stack.yaml
sleep 150
kubectl get pods -n elk -l "release=elastic-stack"  

helm install --name kube-state-metrics --namespace=elk stable/kube-state-metrics
helm install --name elastic-metricbeat --namespace=elk stable/metricbeat -f my-elastic-metricbeat.yaml # metricbeat dashboard 
kubectl --namespace=elk get pods -l "app=metricbeat,release=elastic-metricbeat"

export POD_NAME=$(kubectl get pods -n elk -l "app=kibana,release=elastic-stack" -o jsonpath="{.items[0].metadata.name}");
kubectl port-forward -n elk $POD_NAME 5601:5601

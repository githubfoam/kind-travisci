#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

echo "=============================EFK Elastic Fluentd Kibana============================================================="

helm install elasticsearch stable/elasticsearch
sleep 10

kubectl apply -f app/fluentd-daemonset-elasticsearch.yaml

helm install kibana stable/kibana -f app/kibana-values.yaml

kubectl apply -f app/counter.yaml

# curl kibana dashboard

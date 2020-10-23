#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://github.com/appsecco/kubeseco
echo "===============================deploy kubeseco==========================================================="

# Clone This Repository
git clone https://github.com/appsecco/kubeseco && cd kubeseco

# Deploy Apps and Infra
# setup the cluster
./setup.sh

# Expose API Service
kubectl port-forward service/api-service 3000

# Submit Scan
curl -H "Content-Type: application/json" \
-d '{"asset_type":"domain", "asset_value":"example.com"}' \
http://localhost:3000/scans

# Get Result
# :scan_id is obtained after successful scan submission
# curl http://localhost:3000/scans/:scan_id

echo "===============================deploy kubeseco finished==========================================================="

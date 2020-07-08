#!/bin/bash
set -eox pipefail #safety for script

# https://itnext.io/deploy-your-first-serverless-function-to-kubernetes-232307f7b0a9
echo "============================OpenFaaS =============================================================="
# `curl -sSLf https://cli.openfaas.com | sh` #install the OpenFaaS CLI
# `curl -sSLf https://dl.get-arkade.dev | sh` #install arkade

/bin/sh -c 'curl -sSLf https://cli.openfaas.com | sh' ##install the OpenFaaS CLI
/bin/sh -c 'curl -sSLf https://dl.get-arkade.dev | sh' ##install arkade

arkade install openfaas #use arkade to install OpenFaaS
arkade info openfaas

# Forward the gateway to your machine
kubectl rollout status -n openfaas deploy/gateway
kubectl port-forward -n openfaas svc/gateway 8080:8080 &

# Now log in using the CLI
# PASSWORD=$(kubectl get secret -n openfaas basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode; echo)
# interactive shell
# echo -n $PASSWORD | faas-cli login --username admin --password-stdin

# faas-cli store deploy nodeinfo
# Check to see "Ready" status
# faas-cli describe nodeinfo# Invoke
# echo | faas-cli invoke nodeinfo
# echo | faas-cli invoke nodeinfo --async

# curl http://localhost:8080
# Get the password so you can open the UI
# echo $PASSWORD

# faas-cli template store list
# Sign up for a Docker Hub account, so that you can store your functions for free.
# export OPENFAAS_PREFIX="DOCKER_HUB_USERNAME"
# export OPENFAAS_PREFIX=$DOCKER_USERNAME #travisci env var
# faas-cli new --lang python3 serverless

#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://argoproj.github.io/argo-cd/getting_started/
echo "===============================deploy argocd==========================================================="

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl get service --all-namespaces #list all services in all namespace
kubectl get services #The application will start. As each pod becomes ready, the Istio sidecar will deploy along with it.
kubectl get pods

# echo "===============================deploy argocd finished==========================================================="

# # download the latest Argo CD version from the latest release page of this repository, which will include the argocd CLI
# # https://github.com/argsoproj/argo-cd/releases/tag/v1.7.7

# # view the latest version of Argo CD at the link above or run the following command to grab the version
# VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

# # Replace VERSION in the command below with the version of Argo CD you would like to download:
# curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

# # Make the argocd CLI executable
# chmod +x /usr/local/bin/argocd

# echo "===============================deploy argocd finished==========================================================="

# # download the latest Argo CD version from the latest release page of this repository, which will include the argocd CLI
# # https://github.com/argsoproj/argo-cd/releases/tag/v1.7.7

# # view the latest version of Argo CD at the link above or run the following command to grab the version
# # VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
# VERSION="v1.7.7"

# # Replace VERSION in the command below with the version of Argo CD you would like to download:
# curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

# # Make the argocd CLI executable
# chmod +x /usr/local/bin/argocd

# echo "===============================deploy argocd finished==========================================================="

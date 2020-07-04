#!/bin/bash
echo "=============================deploy kind============================================================="
docker version
export KIND_VERSION="0.8.1"
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v$KIND_VERSION/kind-$(uname)-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind
kind get clusters #see the list of kind clusters
kind get clusters
kubectl config get-contexts #kind is prefixed to the context and cluster names, for example: kind-istio-testing
echo "=============================kubesec============================================================="
#https://github.com/controlplaneio/kubesec
go get -u github.com/controlplaneio/kubesec/cmd/kubesec

#Command line usage
cat <<EOF > kubesec-test.yaml
apiVersion: v1
kind: Pod
metadata:
  name: kubesec-demo
spec:
  containers:
  - name: kubesec-demo
    image: gcr.io/google-samples/node-hello:1.0
    securityContext:
      readOnlyRootFilesystem: true
EOF
kubesec scan kubesec-test.yaml

#Docker usage
docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < kubesec-test.yaml

# Kubesec HTTP Server
kubesec http 8080 &

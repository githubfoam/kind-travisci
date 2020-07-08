#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace

echo "=============================install go============================================================="
export GOVERSION="1.14.4"
curl -O https://dl.google.com/go/go$GOVERSION.linux-amd64.tar.gz
tar -xvf go$GOVERSION.linux-amd64.tar.gz
sudo mv go /usr/local
mkdir ~/work
echo "export GOPATH=$HOME/work" >> ~/.profile
echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> ~/.profile
source ~/.profile
go version

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

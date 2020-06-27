#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script

# https://www.kubeflow.org/docs/started/workstation/minikube-linux/
echo "=============================kubeflow============================================================="
# #Install Docker CE
# docker run hello-world
#
# #Install kubectl
# curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.15.0/bin/linux/amd64/kubectl
# chmod +x ./kubectl
# mv ./kubectl /usr/local/bin/kubectl
#
# # Install Minikube
# curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.2.0/minikube-linux-amd64
# chmod +x minikube
# cp minikube /usr/local/bin/
# rm minikube
# #starts Minikube with 6 CPUs, 12288 memory, 120G disk size
# minikube start --vm-driver=none --cpus 6 --memory 12288 --disk-size=120g --extra-config=apiserver.authorization-mode=RBAC --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf --extra-config kubeadm.ignore-preflight-errors=SystemVerification

# Installation of Kubeflow
# Download the kfctl v1.0.2 release
# https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz
# wget -nv https://github.com/kubeflow/kfctl/releases/download/v1.0.2/kfctl_v1.0.2-0-ga476281_linux.tar.gz
# Unpack the tar ball
# tar -xvf kfctl_v1.0.2_<platform>.tar.gz
# tar -xvf kfctl_v1.0.2-0-ga476281_linux.tar.gz


# The following command is optional, to make kfctl binary easier to use.
# export PATH=$PATH:<path to where kfctl was unpacked>
export PATH=$PATH:kfctl

# Set KF_NAME to the name of your Kubeflow deployment. This also becomes the
# name of the directory containing your configuration.
# For example, your deployment name can be 'my-kubeflow' or 'kf-test'.
# export KF_NAME=<your choice of name for the Kubeflow deployment>

# Set the path to the base directory where you want to store one or more
# Kubeflow deployments. For example, /opt/.
# Then set the Kubeflow application directory for this deployment.
# export BASE_DIR=<path to a base directory>
# export KF_DIR=${BASE_DIR}/${KF_NAME}

# Set the configuration file to use, such as the file specified below:
# export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_k8s_istio.v1.0.2.yaml"
# Generate and deploy Kubeflow:
# mkdir -p ${KF_DIR}
# cd ${KF_DIR}
# kfctl apply -V -f ${CONFIG_URI}

mkdir -p /tmp/kubeflow/v1.0
cd /tmp/kubeflow/v1.0
wget -nv https://github.com/kubeflow/kfctl/releases/download/v1.0/kfctl_v1.0-0-g94c35cf_linux.tar.gz

tar -xvf kfctl_v1.0-0-g94c35cf_linux.tar.gz
export PATH=$PATH:/tmp/kubeflow/v1.0
export KF_NAME=my-kubeflow
export BASE_DIR=/tmp/kubeflow/v1.0
export KF_DIR=${BASE_DIR}/${KF_NAME}
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_k8s_istio.v1.0.2.yaml"

mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_URI}

echo echo "Waiting for kubeflowto be ready ..."
for i in {1..60}; do # Timeout after 5 minutes, 60x5=300 secs
      if kubectl get pods --namespace=kubeflow  | grep ContainerCreating ; then
        sleep 10
      else
        break
      fi
done

kubectl get pod -n kubeflow


#access the Kubeflow dashboard using the istio-ingressgateway service
#see settings for the istio-ingressgateway service
# export INGRESS_HOST=$(minikube ip)
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

# access the Kubeflow dashboard
# http://<INGRESS_HOST>:<INGRESS_PORT>
echo $(curl http://$INGRESS_HOST:$INGRESS_PORT)

# The MNIST on-prem notebook builds a Docker image, launches a TFJob to train a model,
# and creates an InferenceService (KFServing) to deploy the trained model.
# Set up Python environment Python 3.5 or later
apt-get update && apt-get install -qqy wget bzip2


wget -nv https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -p $HOME/miniconda
export PATH="$HOME/miniconda/bin:$PATH"
hash -r
conda --version

conda config --set always_yes yes --set changeps1 no
conda update -q conda
conda info -a

conda create -n mlpipeline python=3.7
conda init
source activate mlpipeline

# Install Jupyter Notebooks
pip install --upgrade pip
pip install jupyter

# Create a namespace to run the MNIST on-prem notebook
kubectl create ns mnist
kubectl label namespace mnist serving.kubeflow.org/inferenceservice=enabled

# Download the MNIST on-prem notebook
cd /tmp/kubeflow
git clone https://github.com/kubeflow/fairing.git



# Launch Jupyter Notebook
cd /tmp/kubeflow/fairing/examples/mnist
conda info --envs #list all discoverable environments
conda activate mlpipeline #Could not find conda environment: mlpipeline
# docker login
jupyter notebook --allow-root &

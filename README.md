# kind-travisci
kind pipeline

Travis (.com) dev branch:
[![Build Status](https://travis-ci.com/githubfoam/kind-travisci.svg?branch=master)](https://travis-ci.com/githubfoam/kind-travisci)  

~~~~
kind is a tool for running local Kubernetes clusters using Docker container “nodes”.
kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.
https://kind.sigs.k8s.io/
~~~~

~~~~
Cluster Mesh
simulate Cluster Mesh in a sandbox
https://docs.cilium.io/en/stable/gettingstarted/kind/
~~~~
~~~~
Hubble
Hubble is a fully distributed networking and security observability platform for cloud native workloads. It is built on top of Cilium and eBPF to enable deep visibility into the communication and behavior of services as well as the networking infrastructure in a completely transparent manner.
https://docs.cilium.io/en/stable/gettingstarted/kind/
~~~~

~~~~
cilium kind
uses kind to demonstrate deployment and operation of Cilium in a multi-node Kubernetes cluster running locally on Docker.
https://docs.cilium.io/en/stable/gettingstarted/kind/
~~~~
~~~~
Weave Scope
https://www.weave.works/oss/scope/
Kubeflow Fairing
https://www.kubeflow.org/docs/fairing/
~~~~
smoke tests openEBS
~~~~
NAMESPACE              NAME                                                      READY   STATUS    RESTARTS   AGE
openebs              maya-apiserver-5d87746c75-27vx6                         1/1     Running             0          11m

openebs              openebs-admission-server-766f5d7c48-9wnm8               1/1     Running             0          11m

openebs              openebs-localpv-provisioner-695ffd78d6-z8h2t            1/1     Running             0          11m

openebs              openebs-ndm-operator-58ccd48f9d-gddnq                   1/1     Running             1          11m

openebs              openebs-ndm-rstjm                                       0/1     ContainerCreating   0          10m

openebs              openebs-provisioner-64c9565ccb-tqlpt                    1/1     Running             0          11m

openebs              openebs-snapshot-operator-cf5cc6c54-62xf9               2/2     Running             0          11m
~~~~

smoke tests k8s dashboard
~~~~
NAMESPACE              NAME                                                      READY   STATUS    RESTARTS   AGE
kubernetes-dashboard   dashboard-metrics-scraper-6b4884c9d5-5l8dl                1/1     Running   0          26s

kubernetes-dashboard   kubernetes-dashboard-7bfbb48676-4pdck                     1/1     Running   0          26s
~~~~
~~~~
The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters
https://kubernetes.io/docs/tasks/tools/install-kubectl/
~~~~
~~~~
The conntrack-tools are a set of free software userspace tools for Linux that allow system administrators interact with the Connection Tracking System, which is the module that provides stateful packet inspection for iptables. The conntrack-tools are the userspace daemon conntrackd and the command line interface conntrack.

The userspace daemon conntrackd can be used to enable high availability of cluster-based stateful firewalls and to collect statistics of the stateful firewall use
http://conntrack-tools.netfilter.org/
~~~~



~~~~
kind is a tool for running local Kubernetes clusters using Docker container “nodes”.
kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.
https://kind.sigs.k8s.io/
~~~~

~~~~
Please use the latest Go version.
To use kind, you will also need to install docker.
Install the latest version of kind.

https://istio.io/docs/setup/platform-setup/kind/

Quick Start
https://kind.sigs.k8s.io/docs/user/quick-start
~~~~

~~~~
Kubernetes auditing provides a security-relevant chronological set of records documenting the sequence of activities that have affected system by individual users, administrators or other components of the system. It allows cluster administrator to answer the following questions:

    what happened?
    when did it happen?
    who initiated it?
    on what did it happen?
    where was it observed?
    from where was it initiated?
    to where was it going?
https://kubernetes.io/docs/tasks/debug-application-cluster/audit/
~~~~

~~~~
Bootstrapping Gardener
https://istio.io/docs/setup/platform-setup/gardener/

Preparing the Setup
Conceptually, all Gardener components are designated to run inside as a Pod inside a Kubernetes cluster.
https://github.com/gardener/gardener/blob/master/docs/development/local_setup.md
~~~~

~~~~
Installing Chocolatey
https://chocolatey.org/docs/installation
Install Homebrew
https://brew.sh/
~~~~

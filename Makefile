IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-voting-app:
	bash app/deploy-voting-app.sh
	
deploy-chaosmesh:
	bash app/deploy-chaosmesh.sh

deploy-elk:
	bash app/deploy-elk.sh

deploy-efk:
	bash app/deploy-efk.sh

provision-helm:
	bash app/provision-helm.sh

provision-kubectl:
	bash app/provision-kubectl.sh

deploy-openfaas:
	bash app/deploy-openfaas.sh

deploy-kubesec:
	bash app/deploy-kubesec.sh

deploy-kind:
	bash deploy-kind.sh

deploy-microservices:
	bash app/deploy-microservices.sh

deploy-cilium-cluster-mesh:
	bash app/deploy-cilium-cluster-mesh.sh

deploy-cilium-hubble-dist:
	bash app/deploy-cilium-hubble-dist.sh

deploy-cilium-hubble-local:
	bash app/deploy-cilium-hubble-local.sh

deploy-cilium:
	bash app/deploy-cilium.sh

deploy-kubeflow:
	bash app/deploy-kubeflow.sh

deploy-openesb:
	bash app/deploy-openesb.sh

deploy-weavescope:
	bash app/deploy-weavescope.sh

deploy-istio:
	bash app/deploy-istio.sh

deploy-dashboard:
	bash app/deploy-dashboard.sh

deploy-dashboard-helm:
	bash app/deploy-dashboard-helm.sh

push-image:
	docker push $(IMAGE)
.PHONY: deploy-kind deploy-openesb deploy-dashboard deploy-dashboard-helm deploy-istio push-image

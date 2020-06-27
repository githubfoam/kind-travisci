IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-kind:
	bash deploy-kind.sh
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

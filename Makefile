IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-kind:
	bash deploy-kind.sh

deploy-openesb:
	bash app/deploy-openesb.sh

push-image:
	docker push $(IMAGE)

.PHONY: deploy-kind deploy-openesb push-image
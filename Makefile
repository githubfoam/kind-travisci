IMAGE := alpine/fio
APP:="app/deploy-openesb.sh"

deploy-openesb:
	bash app/deploy-openesb.sh

push-image:
	docker push $(IMAGE)

.PHONY: build-image push-image

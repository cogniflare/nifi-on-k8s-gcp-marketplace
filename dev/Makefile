TAG := 0.0.22
PROJECT_ID := prj-d-sandbox-364708/calleido-nifi

release-nifi-calleido:
	@docker pull --platform linux/amd64 apache/nifi:latest
	@docker tag apache/nifi:latest gcr.io/$(PROJECT_ID):$(TAG)
	@docker push gcr.io/$(PROJECT_ID):$(TAG)

release-tester:
	@docker buildx build --push --platform linux/amd64 --tag gcr.io/$(PROJECT_ID)/tester:$(TAG) ../apptest/tester

release-deployer:
	@docker buildx build --push --platform linux/amd64 --build-arg MARKETPLACE_TOOLS_TAG=latest \
        --build-arg REGISTRY=gcr.io/$(PROJECT_ID) \
        --build-arg TAG=$(TAG) \
        --tag gcr.io/$(PROJECT_ID)/deployer:$(TAG) -f ../deployer/Dockerfile ../

release: release-nifi-calleido release-tester release-deployer
	@sed -i '/TRACK ?=/c\TRACK ?= $(TAG)' ../Makefile

update-chart:
	@cd ../chart/calleido-deps && helm dependency update
	@cd ../chart/calleido-nifi && helm dependency update

test-doctor:
	KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev doctor

test:
	KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev /scripts/verify --deployer=gcr.io/${PROJECT_ID}/deployer:${TAG}

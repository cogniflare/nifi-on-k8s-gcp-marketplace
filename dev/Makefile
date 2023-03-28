TAG := 1.0.0

REGISTRY := gcr.io/prj-d-sandbox-364708
PROJECT_ID := $(REGISTRY)/calleido-nifi

release-prd: export REGISTRY=eu.gcr.io/prj-cogniflare-marketpl-public
release-prd: export PROJECT_ID=$(REGISTRY)/calleido-nifi

release-nifi-calleido:
	@docker pull --platform linux/amd64 apache/nifi:1.20.0
	@docker tag apache/nifi:1.20.0 $(PROJECT_ID):$(TAG)
	@docker push $(PROJECT_ID):$(TAG)

release-deps:
	@echo rrr $(REGISTRY)
	@echo ppp $(PROJECT_ID)
	# cert-manager-controller
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-controller:v1.10.1
	@docker tag quay.io/jetstack/cert-manager-controller:v1.10.1 $(PROJECT_ID)/cert-manager:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager:$(TAG)
	# cert-manager-webhook
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-webhook:v1.10.1
	@docker tag quay.io/jetstack/cert-manager-webhook:v1.10.1 $(PROJECT_ID)/cert-manager-webhook:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager-webhook:$(TAG)
	# cert-manager-cainjector
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-cainjector:v1.10.1
	@docker tag quay.io/jetstack/cert-manager-cainjector:v1.10.1 $(PROJECT_ID)/cert-manager-cainjector:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager-cainjector:$(TAG)
	# zookeeper
	@docker pull --platform linux/amd64 docker.io/bitnami/zookeeper:3.8.0-debian-11-r56
	@docker tag docker.io/bitnami/zookeeper:3.8.0-debian-11-r56 $(PROJECT_ID)/zookeeper:$(TAG)
	@docker push $(PROJECT_ID)/zookeeper:$(TAG)
	# nifikop operator
	@docker pull --platform linux/amd64 ghcr.io/konpyutaika/docker-images/nifikop:v1.1.0-release
	@docker tag ghcr.io/konpyutaika/docker-images/nifikop:v1.1.0-release $(PROJECT_ID)/nifikop:$(TAG)
	@docker push $(PROJECT_ID)/nifikop:$(TAG)

release-tester:
	@docker buildx build --push --platform linux/amd64 --tag $(PROJECT_ID)/tester:$(TAG) ../apptest/tester

release-deployer:
	@docker buildx build --push --platform linux/amd64 --build-arg MARKETPLACE_TOOLS_TAG=latest \
        --build-arg REGISTRY=$(REGISTRY) \
        --build-arg TAG=$(TAG) \
        --tag $(PROJECT_ID)/deployer:$(TAG) -f ../deployer/Dockerfile ../

release: release-deps release-nifi-calleido release-deployer release-tester
	@sed -i '/TRACK ?=/c\TRACK ?= $(TAG)' ../Makefile

release-prd: release-deps release-nifi-calleido release-deployer release-tester
	@sed -i '/TRACK ?=/c\TRACK ?= $(TAG)' ../Makefile

update-chart:
	@cd ../chart/calleido-deps && helm dependency update
	@cd ../chart/calleido-nifi && helm dependency update

test-doctor:
	KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev doctor

test:
	KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev /scripts/verify --deployer=gcr.io/${PROJECT_ID}/deployer:${TAG}

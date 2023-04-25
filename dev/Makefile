TAG := 1.3
TAG_MINOR := $(TAG).0

REGISTRY := gcr.io/prj-d-sandbox-364708
PROJECT_ID := $(REGISTRY)/calleido-nifi

ifdef PRD_RELEASE
	REGISTRY := gcr.io/prj-cogniflare-marketpl-public
    PROJECT_ID := $(REGISTRY)/calleido-nifi
endif

release-nifi-calleido:
	@docker pull --platform linux/amd64 apache/nifi:1.20.0
	@docker tag apache/nifi:1.20.0 $(PROJECT_ID):$(TAG)
	@docker tag apache/nifi:1.20.0 $(PROJECT_ID):$(TAG_MINOR)
	@docker push $(PROJECT_ID):$(TAG)
	@docker push $(PROJECT_ID):$(TAG_MINOR)

release-deps:
	# cert-manager-controller
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-controller:v1.10.1
	@docker tag quay.io/jetstack/cert-manager-controller:v1.10.1 $(PROJECT_ID)/cert-manager:$(TAG)
	@docker tag quay.io/jetstack/cert-manager-controller:v1.10.1 $(PROJECT_ID)/cert-manager:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/cert-manager:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager:$(TAG_MINOR)
	# cert-manager-webhook
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-webhook:v1.10.1
	@docker tag quay.io/jetstack/cert-manager-webhook:v1.10.1 $(PROJECT_ID)/cert-manager-webhook:$(TAG)
	@docker tag quay.io/jetstack/cert-manager-webhook:v1.10.1 $(PROJECT_ID)/cert-manager-webhook:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/cert-manager-webhook:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager-webhook:$(TAG_MINOR)
	# cert-manager-cainjector
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-cainjector:v1.10.1
	@docker tag quay.io/jetstack/cert-manager-cainjector:v1.10.1 $(PROJECT_ID)/cert-manager-cainjector:$(TAG)
	@docker tag quay.io/jetstack/cert-manager-cainjector:v1.10.1 $(PROJECT_ID)/cert-manager-cainjector:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/cert-manager-cainjector:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager-cainjector:$(TAG_MINOR)
	# zookeeper
	@docker pull --platform linux/amd64 docker.io/bitnami/zookeeper:3.8.1-debian-11-r17
	@docker tag docker.io/bitnami/zookeeper:3.8.1-debian-11-r17 $(PROJECT_ID)/zookeeper:$(TAG)
	@docker tag docker.io/bitnami/zookeeper:3.8.1-debian-11-r17 $(PROJECT_ID)/zookeeper:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/zookeeper:$(TAG)
	@docker push $(PROJECT_ID)/zookeeper:$(TAG_MINOR)
	# nifikop operator
	@docker pull --platform linux/amd64 ghcr.io/konpyutaika/docker-images/nifikop:v1.1.0-release
	@docker tag ghcr.io/konpyutaika/docker-images/nifikop:v1.1.0-release $(PROJECT_ID)/nifikop:$(TAG)
	@docker tag ghcr.io/konpyutaika/docker-images/nifikop:v1.1.0-release $(PROJECT_ID)/nifikop:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/nifikop:$(TAG)
	@docker push $(PROJECT_ID)/nifikop:$(TAG_MINOR)
	# billing - ubbagent
	@docker pull --platform linux/amd64 gcr.io/cloud-marketplace-tools/metering/ubbagent:0.1.1
	@docker tag gcr.io/cloud-marketplace-tools/metering/ubbagent:0.1.1 $(PROJECT_ID)/ubbagent:$(TAG)
	@docker tag gcr.io/cloud-marketplace-tools/metering/ubbagent:0.1.1 $(PROJECT_ID)/ubbagent:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/ubbagent:$(TAG)
	@docker push $(PROJECT_ID)/ubbagent:$(TAG_MINOR)

release-tester:
	@docker buildx build --push --platform linux/amd64 \
		--tag $(PROJECT_ID)/tester:$(TAG) --tag $(PROJECT_ID)/tester:$(TAG_MINOR) ../apptest/tester

release-deployer:
	@docker buildx build --push --platform linux/amd64 --build-arg MARKETPLACE_TOOLS_TAG=latest \
        --build-arg REGISTRY=$(REGISTRY) \
        --build-arg TAG=$(TAG_MINOR) \
        --tag $(PROJECT_ID)/deployer:$(TAG) --tag $(PROJECT_ID)/deployer:$(TAG_MINOR) \
        -f ../deployer/Dockerfile ../

release: update-chart release-deps release-nifi-calleido release-deployer release-tester
	@sed -i '/TRACK ?=/c\TRACK ?= $(TAG_MINOR)' ../Makefile

update-chart:
	@cd ../chart/calleido-deps && helm dependency update
	@cd ../chart/calleido-nifi && helm dependency update

test-doctor:
	KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev doctor

test:
	KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev /scripts/verify --deployer=gcr.io/${PROJECT_ID}/deployer:${TAG}

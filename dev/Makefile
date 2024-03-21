TAG := 1.26
TAG_MINOR := $(TAG).0

TAG_APACHE_NIFI := 1.25.0
TAG_CERT_MANAGER := v1.12.7
TAG_ZOOKEEPER := 3.8.3-debian-11-r2
TAG_NIFIKOP := v1.1.0-release
TAG_UBBAGENT := 0.1.2

REGISTRY := gcr.io/prj-d-sandbox-364708
PROJECT_ID := $(REGISTRY)/calleido-nifi

ifdef PRD_RELEASE
	REGISTRY := gcr.io/prj-cogniflare-marketpl-public
    PROJECT_ID := $(REGISTRY)/calleido-nifi
endif

# https://hub.docker.com/r/apache/nifi/tags
# CVE-2016-1000027: https://issues.apache.org/jira/browse/NIFI-11703
release-nifi-calleido:
	@echo "*** Building and pushing nifi image"
	@docker pull --platform linux/amd64 apache/nifi:$(TAG_APACHE_NIFI)
	@docker tag apache/nifi:$(TAG_APACHE_NIFI) $(PROJECT_ID):$(TAG)
	@docker tag apache/nifi:$(TAG_APACHE_NIFI) $(PROJECT_ID):$(TAG_MINOR)
	@docker push $(PROJECT_ID):$(TAG)
	@docker push $(PROJECT_ID):$(TAG_MINOR)

# custom build based on 1.21.0
#release-nifi-calleido:
#	@docker pull --platform linux/amd64 gcr.io/prj-cogniflare-marketpl-public/calleido-nifi/apache/nifi:1.21.0-amd64-cogniflare1
#	@docker tag gcr.io/prj-cogniflare-marketpl-public/calleido-nifi/apache/nifi:1.21.0-amd64-cogniflare1 $(PROJECT_ID):$(TAG)
#	@docker tag gcr.io/prj-cogniflare-marketpl-public/calleido-nifi/apache/nifi:1.21.0-amd64-cogniflare1 $(PROJECT_ID):$(TAG_MINOR)
#	@docker push $(PROJECT_ID):$(TAG)
#	@docker push $(PROJECT_ID):$(TAG_MINOR)

release-deps:
	@echo "*** Building and pushing dependencies"
	# cert-manager-controller
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-controller:$(TAG_CERT_MANAGER)
	@docker tag quay.io/jetstack/cert-manager-controller:$(TAG_CERT_MANAGER) $(PROJECT_ID)/cert-manager:$(TAG)
	@docker tag quay.io/jetstack/cert-manager-controller:$(TAG_CERT_MANAGER) $(PROJECT_ID)/cert-manager:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/cert-manager:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager:$(TAG_MINOR)
	# cert-manager-webhook
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-webhook:$(TAG_CERT_MANAGER)
	@docker tag quay.io/jetstack/cert-manager-webhook:$(TAG_CERT_MANAGER) $(PROJECT_ID)/cert-manager-webhook:$(TAG)
	@docker tag quay.io/jetstack/cert-manager-webhook:$(TAG_CERT_MANAGER) $(PROJECT_ID)/cert-manager-webhook:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/cert-manager-webhook:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager-webhook:$(TAG_MINOR)
	# cert-manager-cainjector
	@docker pull --platform linux/amd64 quay.io/jetstack/cert-manager-cainjector:$(TAG_CERT_MANAGER)
	@docker tag quay.io/jetstack/cert-manager-cainjector:$(TAG_CERT_MANAGER) $(PROJECT_ID)/cert-manager-cainjector:$(TAG)
	@docker tag quay.io/jetstack/cert-manager-cainjector:$(TAG_CERT_MANAGER) $(PROJECT_ID)/cert-manager-cainjector:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/cert-manager-cainjector:$(TAG)
	@docker push $(PROJECT_ID)/cert-manager-cainjector:$(TAG_MINOR)
	# zookeeper
	@docker pull --platform linux/amd64 docker.io/bitnami/zookeeper:$(TAG_ZOOKEEPER)
	@docker tag docker.io/bitnami/zookeeper:$(TAG_ZOOKEEPER) $(PROJECT_ID)/zookeeper:$(TAG)
	@docker tag docker.io/bitnami/zookeeper:$(TAG_ZOOKEEPER) $(PROJECT_ID)/zookeeper:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/zookeeper:$(TAG)
	@docker push $(PROJECT_ID)/zookeeper:$(TAG_MINOR)
	# nifikop operator
	@docker pull --platform linux/amd64 ghcr.io/konpyutaika/docker-images/nifikop:$(TAG_NIFIKOP)
	@docker tag ghcr.io/konpyutaika/docker-images/nifikop:$(TAG_NIFIKOP) $(PROJECT_ID)/nifikop:$(TAG)
	@docker tag ghcr.io/konpyutaika/docker-images/nifikop:$(TAG_NIFIKOP) $(PROJECT_ID)/nifikop:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/nifikop:$(TAG)
	@docker push $(PROJECT_ID)/nifikop:$(TAG_MINOR)
	# billing - ubbagent
	@docker pull --platform linux/amd64 gcr.io/cloud-marketplace-tools/metering/ubbagent:$(TAG_UBBAGENT)
	@docker tag gcr.io/cloud-marketplace-tools/metering/ubbagent:$(TAG_UBBAGENT) $(PROJECT_ID)/ubbagent:$(TAG)
	@docker tag gcr.io/cloud-marketplace-tools/metering/ubbagent:$(TAG_UBBAGENT) $(PROJECT_ID)/ubbagent:$(TAG_MINOR)
	@docker push $(PROJECT_ID)/ubbagent:$(TAG)
	@docker push $(PROJECT_ID)/ubbagent:$(TAG_MINOR)

release-tester:
	@echo "*** Building and pushing tester"
	@docker buildx build --push --platform linux/amd64 \
		--tag $(PROJECT_ID)/tester:$(TAG) --tag $(PROJECT_ID)/tester:$(TAG_MINOR) ../apptest/tester

release-deployer:
	@echo "*** Building and pushing deployer"
	@docker buildx build --push --platform linux/amd64 --build-arg MARKETPLACE_TOOLS_TAG=latest \
        --build-arg REGISTRY=$(REGISTRY) \
        --build-arg TAG=$(TAG_MINOR) \
        --provenance=false \
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

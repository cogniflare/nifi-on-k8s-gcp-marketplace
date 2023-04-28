include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := calleido-nifi
APP_ID ?= $(CHART_NAME)
VERIFY_WAIT_TIMEOUT = 1800

TRACK ?= 1.5.0

# SOURCE_REGISTRY ?= marketplace.gcr.io/google
SOURCE_REGISTRY ?= eu.gcr.io/prj-cogniflare-marketpl-public

# Main image HAS TO BE published always under $SOURCE_REGISTRY/$CHART_NAME
IMAGE_CALLEIDO_NIFI ?= $(SOURCE_REGISTRY)/calleido-nifi:$(TRACK)
IMAGE_CERT_MANAGER ?= $(SOURCE_REGISTRY)/calleido-nifi/cert-manager:$(TRACK)
IMAGE_CERT_MANAGER_WEBHOOK ?= $(SOURCE_REGISTRY)/calleido-nifi/cert-manager-webhook:$(TRACK)
IMAGE_CERT_MANAGER_CAINJECTOR ?= $(SOURCE_REGISTRY)/calleido-nifi/cert-manager-cainjector:$(TRACK)
IMAGE_NIFIKOP ?= $(SOURCE_REGISTRY)/calleido-nifi/nifikop:$(TRACK)
IMAGE_ZOOKEEPER = $(SOURCE_REGISTRY)/calleido-nifi/zookeeper:$(TRACK)
IMAGE_UBBAGENT = $(SOURCE_REGISTRY)/calleido-nifi/ubbagent:$(TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_CALLEIDO_NIFI))

# List of images used in application
ADDITIONAL_IMAGES := cert-manager cert-manager-webhook cert-manager-cainjector nifikop zookeeper ubbagent

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-cert-manager :=  $(call get_sha256,$(IMAGE_CERT_MANAGER))
image-cert-manager-webhook := $(call get_sha256,$(IMAGE_CERT_MANAGER_WEBHOOK))
image-cert-manager-cainjector := $(call get_sha256, $(IMAGE_CERT_MANAGER_CAINJECTOR))
image-nifikop := $(call get_sha256, $(IMAGE_NIFIKOP))
image-zookeeper := $(call get_sha256,$(IMAGE_ZOOKEEPER))
image-ubbagent := $(call get_sha256,$(IMAGE_UBBAGENT))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1


APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

# Build tester image
app/build:: .build/$(CHART_NAME)/tester

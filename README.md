# Overview

Calleido-Nifi is basically NiFi on Kubernetes. 

Nifi is a tool that allows users to collect, process, and distribute data between systems. 
It provides a web-based interface that enables users to design and manage data flows in a visual manner, 
using drag-and-drop components.

## About Google Click to Deploy

Popular open stacks on Kubernetes packaged by Google.

# Installation

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install this Calleido-Nifi app to a Google
Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen instructions](https://console.cloud.google.com/marketplace/details/google/calleido-nifi).

## Command line instructions

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/calleido-nifi)

### Prerequisites

#### Set up command-line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, `helm`, `Docker`, and `Git` are installed in your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/reference/kubectl/overview/)
-   [docker](https://docs.docker.com/install/)
-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
-   [helm](https://helm.sh/)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Create a Google Kubernetes Engine cluster

Create a new cluster from the command line:

```shell
export CLUSTER=my-cluster
export ZONE=us-west1-a

gcloud container clusters create "$CLUSTER" --zone "$ZONE"
```

Configure `kubectl` to connect to the new cluster.

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

Navigate to the `calleido-nifi` directory:

```shell
cd click-to-deploy/k8s/calleido-nifi
```

#### Configure the app with environment variables

Choose an instance name and [namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/) for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=calleido-nifi-1
export NAMESPACE=default
```

For the persistent disk provisioning of the Deployments and StatefulSets, you can:

* Change the default StorageClass name. Check your available options using the command below:
    * ```kubectl get storageclass```
    * Or check how to create a new StorageClass in [Kubernetes Documentation](https://kubernetes.io/docs/concepts/storage/storage-classes/#the-storageclass-resource)

* Overwrite the default's persistent disks size.

```shell
export DEFAULT_STORAGE_CLASS="standard" # provide your StorageClass name if not "standard"
# over
export ZOOKEPER_PERSISTENT_DISK_SIZE="10Gi"
```

Set up the image tag:

It is advised to use stable image reference which you can find on
[Marketplace Container Registry](https://marketplace.gcr.io/google/calleido-nifi).
Example:

```shell
export TAG="<BUILD_ID>"
```

Alternatively you can use short tag which points to the latest image for selected version.
> Warning: this tag is not stable and referenced image might change over time.

```shell
export TAG="1.0.0"
```

Configure the container images:

```shell
export IMAGE_HOST="eu.gcr.io"
export IMAGE_REGISTRY="${IMAGE_HOST}/prj-cogniflare-marketpl-public"

export IMAGE_CALLEIDO_NIFI="${IMAGE_REGISTRY}/calleido-nifi"
export IMAGE_CERT_MANAGER="${IMAGE_CALLEIDO_NIFI}/cert-manager"
export IMAGE_CERT_MANAGER_WEBHOOK="${IMAGE_CALLEIDO_NIFI}/cert-manager-webhook"
export IMAGE_CERT_MANAGER_CAINJECTOR="${IMAGE_CALLEIDO_NIFI}/cert-manager-cainjector"
export IMAGE_NIFIKOP="${IMAGE_CALLEIDO_NIFI}/nifikop"
export IMAGE_ZOOKEEPER="/prj-cogniflare-marketpl-public/calleido-nifi/zookeeper"
```

Set or OIDC passwords:

```shell
export OIDC_PASSWORD="xxx"
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than the `default`, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```

#### Expand the manifest template

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to the application.

```shell
helm template "${APP_INSTANCE_NAME}" chart/argo-workflows \
    --namespace "${NAMESPACE}" \
    --set image.repo="${IMAGE_CALLEIDO_NIFI}" \
    --set image.tag="${TAG}" \
    --set calleido-deps.cert-manager.image.repository="${IMAGE_CERT_MANAGER}" \
    --set calleido-deps.cert-manager.image.tag="${TAG}" \
    --set calleido-deps.cert-manager.webhook.image.repository="${IMAGE_CERT_MANAGER_WEBHOOK}" \
    --set calleido-deps.cert-manager.webhook.image.tag="${TAG}" \
    --set calleido-deps.cert-manager.cainjector.image.repository="${IMAGE_CERT_MANAGER_CAINJECTOR}" \
    --set calleido-deps.cert-manager.cainjector.image.tag="${TAG}" \
    --set calleido-deps.nifikop.image.repository="${IMAGE_NIFIKOP}" \
    --set calleido-deps.nifikop.image.tag="${TAG}" \
    --set calleido-deps.zookeeper.image.registry="${IMAGE_HOST}" \
    --set calleido-deps.zookeeper.image.repository="${IMAGE_ZOOKEEPER}" \
    --set calleido-deps.zookeeper.image.tag="${TAG}" \
    --set calleido-deps.zookeeper.persistence.size="${PERSISTENT_DISK_SIZE}" \
    --set calleido-deps.zookeeper.persistence.storageClass="${ZOOKEPER_PERSISTENT_DISK_SIZE}" \
    --set persistence.logs.storageClass="${ZOOKEPER_PERSISTENT_DISK_SIZE}" \
    --set persistence.data.storageClass="${ZOOKEPER_PERSISTENT_DISK_SIZE}" \
    --set persistence.flowFileRepo.storageClass="${ZOOKEPER_PERSISTENT_DISK_SIZE}" \
    --set persistence.conf.storageClass="${ZOOKEPER_PERSISTENT_DISK_SIZE}" \
    --set persistence.contentRepo.storageClass="${ZOOKEPER_PERSISTENT_DISK_SIZE}" \
    --set persistence.provenanceRepo.storageClass="${ZOOKEPER_PERSISTENT_DISK_SIZE}" \
    --set persistence.extensionsRepo.storageClass="${ZOOKEPER_PERSISTENT_DISK_SIZE}" \
    > "${APP_INSTANCE_NAME}_manifest.yaml"
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```

#### View the app in the Google Cloud Console

To get the Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}"
```

To view the app, open the URL in your browser.

# Uninstall the Application

## Using the Google Cloud Platform Console

1.  In the GCP Console, open
    [Kubernetes Applications](https://console.cloud.google.com/kubernetes/application).

1.  From the list of applications, click **Calleido-Nifi**.

1.  On the Application Details page, click **Delete**.

## Using the command line

Run the following to uninstall Calleido-Nifi:

* cd to the Calleido-Nifi directory
* run `make app/uninstall`

### Manually Removing Constraints

If Calleido-Nifi is no longer running and there are extra constraints in the cluster, then the finalizers, CRDs and other artifacts must be removed manually:

* Delete all instances of the constraint resource
* Remove all finalizers on every CRD. If this is not something you want to do, the finalizers must be removed individually.
    ```bash
    kubectl get --no-headers nificluster | awk '{print $1}' | xargs kubectl patch nificluster -p '{"metadata" : {"finalizers" : null }}' --type=merge
    kubectl get --no-headers nifiuser | awk '{print $1}' | xargs kubectl patch nifiuser -p '{"metadata" : {"finalizers" : null }}' --type=merge
    kubectl get --no-headers nifiusergroup | awk '{print $1}' | xargs kubectl patch nifiusergroup -p '{"metadata" : {"finalizers" : null }}' --type=merge
    kubectl delete mutatingwebhookconfigurations --selector  "app.kubernetes.io/name=webhook"
    kubectl delete validatingwebhookconfigurations --selector  "app.kubernetes.io/name=webhook"
    ```
* Delete the `CRD`, `nificluster`, `nifiuser` and `nifiusergroup` resources associated with the unwanted constraint.

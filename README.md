# nifi-on-k8s-gcp-marketplace
Documentation for NiFi on Kubernetes hosted on GCP Marketplace


## Install
```shell
cd ../calleido-deps
helm dep update

cd ../calleido-nifi
helm dep update
helm upgrade --install calleido-nifi . --create-namespace --namespace calleido
```

Now `kgs` -> externalIp
http://34.116.187.71:8080/nifi/

## Uninstall

```shell
helm uninstall calleido-nifi calleido
kubectl delete namespace calleido
kubectl delete crd -l app=cert-manager
kubectl api-resources --api-group=nifi.konpyutaika.com --no-headers -o name | xargs -L1 kubectl delete crd
```
To overwrite default image from Makefile: `export IMAGE_NIFI=apache/nifi:1.12.1`

## Build & Test on GCP

### Requirements
1. Setup K8s cluster and connect to it
2. Install Application CRD: `kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"`
3. Export ENVs:
    ```bash
    export PROJECT_ID=prj-d-sandbox-364708/calleido-nifi
    export TAG=1.0.0-cogniflare5
    export DEPLOYER_TAG=0.1.5
    ```

### Prepare images

Current images path format:
- main: gcr.io/prj-d-sandbox-364708/calleido-nifi
- test: gcr.io/prj-d-sandbox-364708/calleido-nifi/tester
- deployer: gcr.io/prj-d-sandbox-364708/calleido-nifi/deployer

1. Calleido Nifi Controller image
   Re-tag and push to GCR official Calleido Nifi Controller image:
    ```bash
    docker pull --platform linux/amd64 apache/nifi:latest
    docker tag apache/nifi:latest gcr.io/${PROJECT_ID}:${TAG}
    docker push gcr.io/${PROJECT_ID}:${TAG}
    ```
2. Build App tester image
    ```bash
    cd apptest/tester
    docker buildx build --push --platform linux/amd64 --tag gcr.io/${PROJECT_ID}/tester:${TAG} .
    ```
3. Update `TRACK` with `${TAG}` value in [README.MD](Makefile)
4. Build Deployer image
    ```bash
    docker buildx build --push --platform linux/amd64 --build-arg MARKETPLACE_TOOLS_TAG=latest \
        --build-arg REGISTRY=gcr.io/${PROJECT_ID} \
        --build-arg TAG=${TAG} \
        --tag gcr.io/${PROJECT_ID}/deployer:${DEPLOYER_TAG} -f deployer/Dockerfile .
    ```

### Run tests on GCP

### On AMD64 CPU
1. Test K8s config
    ```bash
    KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev doctor
    ```
2. Test deployer
    ```bash
    KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev /scripts/verify --deployer=gcr.io/${PROJECT_ID}/deployer:${DEPLOYER_TAG}
    ```

### On ARM64 CPU
```shell
   docker run --platform linux/amd64 --init --net=host \
   --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly \
   --mount type=bind,source=/tmp/logs,target=/logs \
   -it --rm gcr.io/cloud-marketplace-tools/k8s/dev:latest bash
   
   gcloud auth login
   gcloud config set project prj-d-sandbox-364708
   gcloud container clusters get-credentials cluster-1 --zone us-central1-c --project prj-d-sandbox-364708
   
   /scripts/verify --deployer=gcr.io/prj-d-sandbox-364708/calleido-nifi/deployer:${DEPLOYER_TAG}
```








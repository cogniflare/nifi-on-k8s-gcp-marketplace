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
1. Setup K8s cluster and connect to it (use e2-standart-4 machine type with 1 node)
2. Install Application CRD: `kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"`

### Release images

Current images path format:
- main: gcr.io/prj-d-sandbox-364708/calleido-nifi
- test: gcr.io/prj-d-sandbox-364708/calleido-nifi/tester
- deployer: gcr.io/prj-d-sandbox-364708/calleido-nifi/deployer

To release new version:
1. Bump `TAG` in [Makefile](Makefile)
2. `make release`

### Run tests on GCP

### On AMD64 CPU
1. Test K8s config
    ```bash
    make test-doctor
    ```
2. Test deployer
    ```bash
    make test
    ```

### On ARM64 CPU
`mpdev` is not available for ARM64 CPU, so we need to run tests in docker container manually:
```bash
   docker run --platform linux/amd64 --init --net=host \
   --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly \
   --mount type=bind,source=/tmp/logs,target=/logs \
   -it --rm gcr.io/cloud-marketplace-tools/k8s/dev:latest bash
   
   gcloud auth login
   gcloud config set project prj-d-sandbox-364708
   gcloud container clusters get-credentials cluster-1 --zone us-central1-c --project prj-d-sandbox-364708
   
   /scripts/verify --deployer=gcr.io/prj-d-sandbox-364708/calleido-nifi/deployer:${TAG}
```

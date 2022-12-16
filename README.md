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


Build docker locally
```bash
docker buildx build --load --platform linux/amd64 --build-arg MARKETPLACE_TOOLS_TAG=latest \
    --build-arg REGISTRY=gcr.io/prj-d-sandbox-364708/calleido-nifi \
    --build-arg TAG=1.18.0 \
    --tag gcr.io/prj-d-sandbox-364708/calleido-nifi/deployer:0.0.2 -f deployer/Dockerfile .

docker push gcr.io/prj-d-sandbox-364708/calleido-nifi/deployer:0.0.2

```


Test:
```bash
KUBE_CONFIG=$KUBECONFIG GCLOUD_CONFIG=$CLOUDSDK_CONFIG mpdev /scripts/verify --deployer=gcr.io/prj-d-sandbox-364708/calleido-nifi/deployer:0.0.2
```
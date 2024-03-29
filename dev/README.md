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
1. Setup EKS cluster and connect to it: https://console.cloud.google.com/welcome?project=prj-d-sandbox-364708
   - use `e2-standard-4 machine` Node type
   - use 1 node
2. Install Application CRD:
   ```
   kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
   ```

### Release images

To release a new version:
1. Bump `TAG` in [Makefile](Makefile)
2. Call `make release` to build and push images to GCR (dev)
   For official release, call: `PRD_RELEASE=true make release`

In case of error: `missing content: content digest xxx not found` on `docker push` step, 
disable `containerd` for pulling and storing images in Docker

### Run tests on GCP

#### On AMD64 CPU
1. Test K8s config
    ```bash
    make test-doctor
    ```
2. Test deployer
    ```bash
    make test
    ```

#### On ARM64 CPU

1. Ensure that `marketplace-test` StaticIP address exists in [GCP](https://console.cloud.google.com/networking/addresses/list?project=prj-cogniflare-marketpl-public)
2. Ensure that DNS record exists in [GCP sandbox](https://console.cloud.google.com/net-services/dns/zones/nifikop/details?project=prj-d-sandbox-364708)
   - `marketplace.nifikop.calleido.io.` for `prj-cogniflare-marketpl-public` project
   - `test-dev.nifikop.calleido.io.` for `prj-d-sandbox-364708` project
3. Ensure that your DNS address ic configured in OIDC client in [GCP](https://console.cloud.google.com/apis/credentials/oauthclient/229459469551-7q6uunqocmn9juhg33jcg4vvpcsqf3ug.apps.googleusercontent.com?project=prj-d-sandbox-364708)

`mpdev` is not available for ARM64 CPU, so we need to run tests in docker container manually:
```bash
    docker run --platform linux/amd64 --init --net=host \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,readonly \
    --mount type=bind,source=$(pwd)/log,target=/logs \
    -it --rm gcr.io/cloud-marketplace-tools/k8s/dev:latest bash
    
    #export PROJECT=prj-cogniflare-marketpl-public
    export PROJECT=prj-d-sandbox-364708
    
    gcloud auth login
    gcloud config set project $PROJECT
    gcloud container clusters get-credentials cluster-1 --zone us-central1-c --project $PROJECT
    
    export OAUTH_ID=$(gcloud --project prj-d-sandbox-364708 secrets versions access latest --secret=OauthClientID)
    export OAUTH_SECRET=$(gcloud --project prj-d-sandbox-364708  secrets versions access latest --secret=OauthSecret)

    export ARGS_JSON=$(cat <<EOF
 {
"calleido-deps.nifikop.reportingSecret": "gs://cloud-marketplace-tools/reporting_secrets/fake_reporting_secret.yaml",
"name": "test-nifi",
"namespace": "test-nifi",
"admin.identity": "jakub@cogniflare.io",
"oidc.clientId": "'${OAUTH_ID}'", "oidc.secret": "'${OAUTH_SECRET}'",
"ingress.staticIpAddressName": "marketplace-test", 
"dnsName": "test-dev.nifikop.calleido.io"
}
EOF
)
    
    export TAG=1.26.0
    
    # run automated tests
    /scripts/verify --deployer=gcr.io/$PROJECT/calleido-nifi/deployer:${TAG}
    
    # run manual deployment
    kubectl create namespace test-nifi
    kubectl config set-context --current --namespace=test-nifi
    /scripts/install --deployer=gcr.io/$PROJECT/calleido-nifi/deployer:${TAG} --parameters="$ARGS_JSON"
    
    # remove
    kubectl delete applications.app.k8s.io test-nifi
    
    kubectl get --no-headers nificluster | awk '{print $1}' | xargs kubectl patch nificluster -p '{"metadata" : {"finalizers" : null }}' --type=merge
    kubectl get --no-headers nifiuser | awk '{print $1}' | xargs kubectl patch nifiuser -p '{"metadata" : {"finalizers" : null }}' --type=merge
    kubectl get --no-headers nifiusergroup | awk '{print $1}' | xargs kubectl patch nifiusergroup -p '{"metadata" : {"finalizers" : null }}' --type=merge
    kubectl delete mutatingwebhookconfigurations --selector  "app.kubernetes.io/name=webhook"
    kubectl delete validatingwebhookconfigurations --selector  "app.kubernetes.io/name=webhook"
    kubectl delete namespace test-nifi
```

### Debugging
- Verify SSL cert state: https://console.cloud.google.com/security/ccm/list/lbCertificates

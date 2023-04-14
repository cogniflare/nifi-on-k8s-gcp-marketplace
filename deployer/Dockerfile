ARG MARKETPLACE_TOOLS_TAG

FROM marketplace.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD chart/calleido-nifi /tmp/chart
RUN cd /tmp && tar -czvf /tmp/calleido-nifi.tar.gz chart

ADD apptest/deployer/calleido-nifi /tmp/test/chart
RUN cd /tmp/test \
    && tar -czvf /tmp/test/calleido-nifi.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

ARG REGISTRY
ARG TAG

RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml

ADD apptest/deployer/schema.yaml /tmp/apptest/schema.yaml
RUN cat /tmp/apptest/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/apptest/schema.yaml.new \
    && mv /tmp/apptest/schema.yaml.new /tmp/apptest/schema.yaml

FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm:$MARKETPLACE_TOOLS_TAG

RUN apt-get update \
    && apt-get install -y --no-install-recommends dnsutils netcat \
    && rm -rf /var/lib/apt/lists/*

RUN sed '/^kubectl apply/ikubectl apply -f /data/extracted/calleido-nifi/chart/crds/\n\
    kubectl wait --for=condition=Established --timeout=15s crd clusterissuers.cert-manager.io\n\
    kubectl wait --for=condition=Established --timeout=15s crd nificlusters.nifi.konpyutaika.com' -i /bin/deploy.sh /bin/deploy_with_tests.sh

RUN sed '/--namespace="$NAMESPACE"/c\    --namespace="$NAMESPACE" --set-string calleido-deps.nifikop.namespaces={"$NAMESPACE"} --set-string calleido-deps.cert-manager.global.leaderElection.namespace="$NAMESPACE" --set-string calleido-deps.cert-manager.extraArgs={--namespace="$NAMESPACE"} \\' -i /bin/create_manifests.sh


COPY --from=build /tmp/calleido-nifi.tar.gz /data/chart/
COPY --from=build /tmp/test/calleido-nifi.tar.gz /data-test/chart/
COPY --from=build /tmp/apptest/schema.yaml /data-test/
COPY --from=build /tmp/schema.yaml /data/

ENV WAIT_FOR_READY_TIMEOUT 1200
ENV TESTER_TIMEOUT 1200

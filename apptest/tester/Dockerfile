FROM gcr.io/cloud-marketplace-tools/testrunner:0.1.4

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext \
    jq \
    uuid-runtime \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kubectl/ \
    && wget -q -O /opt/kubectl/kubectl \
       https://storage.googleapis.com/kubernetes-release/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod 755 /opt/kubectl/kubectl \
    && ln -s /opt/kubectl/kubectl /usr/bin/kubectl

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]

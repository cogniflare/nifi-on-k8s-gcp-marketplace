FROM gcr.io/cloud-marketplace-tools/testrunner:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    gettext \
    jq \
    uuid-runtime \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY tests/basic-suite.yaml /tests/basic-suite.yaml
COPY tester.sh /tester.sh

WORKDIR /
ENTRYPOINT ["/tester.sh"]

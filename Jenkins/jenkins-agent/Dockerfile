FROM jenkins/inbound-agent:3395.v6e5377b_0fb_3c-2-jdk25

USER root

RUN apt-get update && apt-get install -y \
    docker.io \
    docker-compose \
    curl \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2
ARG TARGETARCH
RUN case "$TARGETARCH" in \
      amd64) AWS_ARCH=x86_64 ;; \
      arm64) AWS_ARCH=aarch64 ;; \
      *) exit 1 ;; \
    esac && \
    curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" \
    -o /tmp/awscliv2.zip && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# Trivy
RUN wget -qO- https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh \
    | sh -s -- -b /usr/local/bin

USER jenkins

########################################
FROM quay.io/zenlab/curl AS download

WORKDIR /opt

USER root

ARG VERSION="v1.24.7"
RUN case "$(uname -m)" in \
      x86_64) ARCH="amd64";; \
      aarch64* | arm64 | armv8*) ARCH="arm64";; \
      armv7*) ARCH="arm";; \
      i386 | i686) ARCH="386";; \
      ppc64le) ARCH="ppc64le";; \
      s390x) ARCH="s390x";; \
      *) echo "Unexpected architecture: $(uname -m)" && exit 1;; \
    esac && \
    \
    if [ $VERSION = "stable" ]; then \
      VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt); \
    fi && \
    \
    curl -LO https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/kubectl && \
    curl -LO https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/kubectl.sha256 && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum -c && \
    chmod +x kubectl

########################################
FROM quay.io/zenlab/alpine:3
COPY --from=download /opt/kubectl /usr/local/bin/kubectl
USER 65534
ENTRYPOINT [ "/usr/local/bin/kubectl" ]
CMD [ "version" ]

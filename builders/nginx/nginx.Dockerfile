# Copyright VMware, Inc.
# SPDX-License-Identifier: APACHE-2.0

FROM registry.access.redhat.com/ubi9/ubi-minimal

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-11" \
    OS_NAME="linux"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libcrypt1 libgeoip1 libpcre3 libssl1.1 openssl procps zlib1g
RUN mkdir -p /tmp/technobureau/pkg/cache/ ; cd /tmp/technobureau/pkg/cache/ ; \
    COMPONENTS=( \
      "render-template-1.0.6-4-linux-${OS_ARCH}-debian-11" \
      "nginx-1.25.3-1-linux-${OS_ARCH}-debian-11" \
    ) ; \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz.sha256" -O ; \
      fi ; \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" ; \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/technobureau --strip-components=2 --no-same-owner --wildcards '*/files' ; \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done

RUN chmod g+rwX /opt/technobureau
RUN ln -sf /dev/stdout /opt/technobureau/nginx/logs/access.log
RUN ln -sf /dev/stderr /opt/technobureau/nginx/logs/error.log

COPY nginx/rootfs /
RUN /opt/technobureau/scripts/nginx/postunpack.sh
ENV APP_VERSION="1.25.3" \
    TECHNOBUREAU_APP_NAME="nginx" \
    NGINX_HTTPS_PORT_NUMBER="" \
    NGINX_HTTP_PORT_NUMBER="" \
    PATH="/opt/technobureau/common/bin:/opt/technobureau/nginx/sbin:$PATH"

EXPOSE 8080 8443

WORKDIR /app
USER 1001
ENTRYPOINT [ "/opt/technobureau/scripts/nginx/entrypoint.sh" ]
CMD [ "/opt/technobureau/scripts/nginx/run.sh" ]

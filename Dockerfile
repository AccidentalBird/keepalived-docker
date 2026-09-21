FROM alpine:3.23

RUN apk add --no-cache keepalived gettext \
    && adduser -S -D -H -s /sbin/nologin keepalived_script \
    && INSTALLED_VERSION=$(keepalived --version 2>&1 | head -1 | awk '{print $2}') \
    && echo "keepalived version: $INSTALLED_VERSION"

LABEL org.opencontainers.image.title="keepalived-docker" \
      org.opencontainers.image.description="Minimal Alpine-based keepalived image (amd64 + arm64)" \
      org.opencontainers.image.source="https://github.com/AccidentalBird/keepalived-docker" \
      org.opencontainers.image.licenses="MIT"

# NOTE: keepalived requires NET_ADMIN, NET_BROADCAST, and NET_RAW capabilities
# and must run on the host network to manage VIPs. These are architectural
# requirements of VRRP, not fixable by the image.

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD pidof keepalived || exit 1

COPY entrypoint.sh /entrypoint.sh

# The entrypoint renders /etc/keepalived/keepalived.conf.tmpl when one is
# mounted, then execs keepalived. With no template present it execs keepalived
# directly, so a plain mounted config behaves exactly as it did before.
ENTRYPOINT ["/entrypoint.sh"]

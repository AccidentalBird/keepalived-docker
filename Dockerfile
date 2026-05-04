FROM alpine:3.20

RUN apk add --no-cache keepalived bind-tools \
    && adduser -S -D -H -s /sbin/nologin keepalived_script

ENTRYPOINT ["keepalived", "-n", "-l", "-d", "-f", "/etc/keepalived/keepalived.conf"]

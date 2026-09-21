#!/bin/sh
# entrypoint.sh — render a templated keepalived.conf, then exec keepalived.
#
# keepalived has no variable substitution of its own: whatever the mounted
# config says is what VRRP advertises. That forces a separate committed config
# per environment, and a config carrying one environment's addresses is
# unusable in another — a dev instance fed the production file advertises a VIP
# in a subnet it does not own.
#
# So: if a template is mounted, render it with the environment's values before
# starting. Plain-config users are unaffected — with no template present this
# execs keepalived exactly as before.
set -eu

CONF="${KEEPALIVED_CONF:-/etc/keepalived/keepalived.conf}"
TMPL="${KEEPALIVED_CONF_TEMPLATE:-${CONF}.tmpl}"
# The config mount is typically read-only, so render beside it in tmpfs.
RENDERED="${KEEPALIVED_CONF_RENDERED:-/tmp/keepalived.conf}"

log() { echo "[entrypoint] $*"; }

if [ -f "$TMPL" ]; then
    log "rendering $TMPL"

    # Substitute only the KEEPALIVED_-prefixed names this image defines, so a
    # literal $ elsewhere in the config survives untouched. envsubst with an
    # explicit list is safer here than a bare envsubst, which would eat any
    # unrelated $VAR the operator wrote on purpose.
    vars=$(awk 'match($0, /\$\{KEEPALIVED_[A-Z0-9_]+\}/) {
        print substr($0, RSTART, RLENGTH)
    }' "$TMPL" | sort -u | tr '\n' ' ')

    if [ -z "$vars" ]; then
        log "WARNING: $TMPL contains no \${KEEPALIVED_*} placeholders"
    fi

    envsubst "$vars" < "$TMPL" > "$RENDERED"

    # An unexpanded placeholder means a variable was not passed. keepalived
    # would fail to parse it, or parse it as a literal and advertise nothing —
    # both worse than refusing to start with a clear message.
    if grep -q '\${KEEPALIVED_[A-Z0-9_]*}' "$RENDERED"; then
        log "ERROR: unset variables remain after rendering:"
        grep -no '\${KEEPALIVED_[A-Z0-9_]*}' "$RENDERED" | sort -u -t: -k2 >&2
        exit 1
    fi

    log "rendered $vars-> $RENDERED"
    CONF="$RENDERED"
elif [ ! -f "$CONF" ]; then
    log "ERROR: neither $CONF nor $TMPL is present — mount one"
    exit 1
fi

exec keepalived -n -l -d -f "$CONF" "$@"

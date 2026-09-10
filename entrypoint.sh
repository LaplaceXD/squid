#!/bin/sh
set -euo pipefail

: "${PROXY_USERNAME:?PROXY_USERNAME must be set}"
: "${PROXY_PASSWORD:?PROXY_PASSWORD must be set}"

htpasswd -bc /etc/squid/passwd "$PROXY_USERNAME" "$PROXY_PASSWORD"

exec "$@"

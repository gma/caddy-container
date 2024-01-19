#!/usr/bin/env bash


VERSION="$1"
REGISTRY="${2:-docker.io}"
NAMESPACE="${3:-library}"


usage()
{
    echo "Usage: $(basename "$0") <version> [registry] [namespace]" 1>&2
    exit 1
}


[ -z "$VERSION" ] && usage


set -euo pipefail
set +x

docker build \
    --build-arg VERSION="$VERSION" \
    -t "$REGISTRY/$NAMESPACE/caddy-webdav:$VERSION" \
    .

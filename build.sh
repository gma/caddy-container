#!/usr/bin/env bash


VERSION="$1"
REGISTRY="${2:-docker.io}"
NAMESPACE="${3:-library}"
PREFIX="$REGISTRY/$NAMESPACE"

PLATFORM="${PLATFORM:-linux/amd64,linux/arm64,linux/arm/v7}"


usage()
{
    echo "Usage: $(basename "$0") <version> [registry] [namespace]" 1>&2
    exit 1
}


set -euo pipefail
set +x

[ -z "$VERSION" ] && usage

docker buildx build \
    --builder=container \
    --build-arg VERSION="$VERSION" \
    --platform "$PLATFORM" \
    --push \
    -t "$PREFIX/caddy-webdav:$VERSION" \
    -t "$PREFIX/caddy-webdav:latest" \
    .

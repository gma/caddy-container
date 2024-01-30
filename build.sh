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

PREFIX="$REGISTRY/$NAMESPACE"

cat <<EOF

If $VERSION is the latest release, you could also create a latest tag:

docker tag $PREFIX/caddy-webdav:$VERSION $PREFIX/caddy-webdav:latest

Push them with:

docker push $PREFIX/caddy-webdav:$VERSION
docker push $PREFIX/caddy-webdav:latest

EOF

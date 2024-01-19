caddy-webdav-container
======================

This is a really simple repository, containing a `Dockerfile` that you
can use to build a Caddy image that includes support for WebDAV.

To use it, run the build script and specify the version of Caddy that
you'd like to use. You can use any of the tags on the [official Caddy
image].

e.g.

    ./build.sh 2.7.6
    ./build.sh latest

You can also (optionally) specify a namespace and a registry, which will
be used in your tag:

    ./build.sh <version> [hostname[:port]] [namespace]

The hostname defaults to "docker.io" and the namespace defaults to
"library".

So if you were to run:

    ./build.sh 2.7.6 registry.local

…then you'd build a Caddy 2.7.6 image with WebDAV support compiled in,
named "registry.local/library/caddy-webdav" and tagged with "2.7.6".

You could then push it to your registry with:

    docker push registry.local/library/caddy-webdav:2.7.6

[official Caddy image]: https://hub.docker.com/_/caddy

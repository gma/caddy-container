caddy-webdav-container
======================

This is a simple repository, containing docs and scripts that are useful
for building container images for running the [Caddy] web server with
[support for WebDAV].

If you'd like to build an image that supports a single architecture, you
can use the [Dockerfile] in this repository to build yourself one.

You might be wondering why I haven't pushed the image up to Docker Hub
so that all you need to do is pull it down yourself. In a word, the
answer is "security". We shouldn't use random Docker images that we find
on Docker Hub; you've no idea what might be in it, or what might sneak
into it in future.

I'm not going to use somebody else's, and neither should you. That
doesn't mean that I can't do a load of the work for you though. Take a
look at the [Dockerfile] and you'll see that it's very short and easy to
understand. All it does is use the official Caddy builder image to
compile a version of Caddy with the [mholt/caddy-webdav] module included.

To build it on your machine, you can just clone this repository and then
run:

    docker build --build-arg VERSION=2.7.6 \
        -t caddy-webdav:2.7.6 \
        -t caddy-webdav:latest \
        .

Note the `VERSION` argument, that specifies which version of Caddy we're
going to build. 2.7.6 is the latest at the time of writing; see the
[official Caddy image page] for a list of the latest available versions.

[Caddy]: https://caddyserver.com
[official Caddy image page]: https://hub.docker.com/_/caddy
[support for WebDAV]: https://github.com/mholt/caddy-webdav
[mholt/caddy-webdav]: https://github.com/mholt/caddy-webdav
[Dockerfile]: ./Dockerfile

Getting setup for multi-platform images
---------------------------------------

If all you need is an image that you can install locally (or on a
machine that's running the same architecture), the above docs and build
command are probably all you need.

I run Caddy on a variety of hardware (e.g. x86 machines and low powered
ARM devices). So I want a [multi-platform image] that supports
`linux/amd64` and `linux/arm/v7` architectures, that I can publish on my
own private Docker Registry.

The rest of the files in this repository (and the rest of this README)
are here to make building those multi-platform images straightforward.

To build Caddy for multiple architectures we need to run the build
process inside a virtual machine. Docker's buildkit can take care of
this for us, via it's [docker-container driver]. To use it we need to
create a new builder, and then use it when we build the Caddy image.

But there's one more thing I should explain first…

At the end of the multi-platform build, Docker can push our completed
images to a registry for us. This is behaviour I need; I push them to a
privately hosted registry that's secured with a self-signed Certificate
Authority (CA) certificate. Unfortunately, the build container doesn't
recognise my registry's self-signed certificate, so Docker can't push my
Caddy images to it without a bit of help.

To workaround that problem I've made a slightly modified build
container, that's created using [Dockerfile.buildkit].

That's a lot of explanation, in practice it's quite straightforward. The
first time I build a multi-platform image on my workstation, I start by
creating my custom build container:

    cp ../path/to/my-registry-cert.crt ./registry.crt
    docker build -f Dockerfile.buildkit -t buildkit-cert:latest .

Then I use my new `buildkit-cert:latest` image to setup builder so it
can handle a multi-platform build (i.e. a builder that uses the
[docker-container driver]):

    docker buildx create --name container \
        --driver=docker-container
        --driver-opt=image=buildkit-cert:latest

If you're following along, and you don't need to push to a registry that
has an unrecognised certificate, you don't need to build the custom
image, or pass the `--driver-opt` switch to `docker buildx create`.

Note the name of the builder that we've created is set to "container".
That's not critical, but beware that the `build.sh` script that I use to
build the Caddy image (below) has that name hard coded within it.

Run `docker buildx ls` to list your available builders and their drivers
(you should also have one called "default").

[multi-platform image]: https://docs.docker.com/build/building/multi-platform/
[docker-container driver]: https://docs.docker.com/build/drivers/docker-container/
[Dockerfile.buildkit]: ./Dockerfile.buildkit

Building a multi-platform caddy image
-------------------------------------

After all that prep, you're ready to build a Caddy image with webdav
support, that'll run on multiple CPU architectures.

To ensure that I do this consistently every time, I wrote the `build.sh`
script. It takes up to 3 arguments:

    ./build.sh <version> [hostname[:port]] [namespace]

At a minimum, you have to specify the version of Caddy that you'd like
to use. You can use any of the tags on the [official Caddy image page].

e.g.

    ./build.sh 2.7.6

You can also (optionally) specify a namespace and a registry, which will
be used in your tag.

The hostname defaults to "docker.io" and the namespace defaults to
"library".

By default it builds an image that supports three architectures:
`linux/amd64`, `linux/arm64`, and `linux/arm/v7`. You can override that
behaviour by setting the `PLATFORM` environment variable:

    PLATFORM="linux/amd64,linux/arm64" ./build.sh 2.7.6

So, to summarise, if you were to run it like this (as I do):

    ./build.sh 2.7.6 registry.local

…then you'd:

- use your new docker-container driver to…
- build a Caddy 2.7.6 image with WebDAV support compiled in,
- named "registry.local/library/caddy-webdav" and tagged with "2.7.6", and
- Docker would push it to `registry.local`

You might be wondering why it pushes automatically. It's because a
multi-platform image can't be loaded into your local image store, and if
we didn't push it then at the end of the build process the images would
[only be available][issue] in Docker's build cache. You wouldn't be able to
create containers from them, for example.

Also, because I always push a new image to my local registry, it just
makes sense for me to push them automatically.

[issue]: https://github.com/docker/buildx/issues/59

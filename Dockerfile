FROM caddy:2.7-builder AS builder

RUN xcaddy build --with github.com/mholt/caddy-webdav

FROM caddy:2.7

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

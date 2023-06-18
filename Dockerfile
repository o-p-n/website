ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM lukechannings/deno:v1.30.2 AS builder

WORKDIR /working
RUN mkdir -p /working
COPY . /working
RUN deno task build

FROM docker.io/linuxwolf/serveit:dc3030b4729cb58a8654f87ef05ff454a911c095 AS website

COPY --from=builder /working/_site /app/web

ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM lukechannings/deno:v1.30.2 AS builder

WORKDIR /working
RUN mkdir -p /working
COPY . /working
RUN deno task build

FROM docker.io/linuxwolf/serveit:de3717fea8da06b32e7476e9816aac03a8abef95 AS website

COPY --from=builder /working/_site /app/web

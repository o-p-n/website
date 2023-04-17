ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM lukechannings/deno:v1.30.2 AS builder

WORKDIR /working
RUN mkdir -p /working
COPY . /working
RUN deno task build

FROM docker.io/linuxwolf/serveit:9eada6ad3028092e6bf5a1b82c67c18c1cbd8f0e AS website

COPY --from=builder /working/_site /app/web

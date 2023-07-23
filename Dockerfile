ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM lukechannings/deno:v1.30.2 AS builder

WORKDIR /working
RUN mkdir -p /working
COPY . /working
RUN deno task build

FROM ghcr.io/o-p-n/serveit:e5a67a0945337aa4701063fe53826661c2721e41 AS website

COPY --from=builder /working/_site /app/web

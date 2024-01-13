ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM lukechannings/deno:v1.39.2 AS builder

WORKDIR /working
RUN mkdir -p /working
COPY . /working
RUN deno task build

FROM ghcr.io/o-p-n/serveit:89ed2e96485680f463a3664eb32ae6031eacad1b AS website

COPY --from=builder /working/_site /app/web

ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM lukechannings/deno:v1.30.2 AS builder

WORKDIR /working
RUN mkdir -p /working
COPY . /working
RUN deno task build

FROM docker.io/linuxwolf/serveit:70c3729aaed5ed4b8405e6bece694f5c65d7b293 AS website

COPY --from=builder /working/_site /app/web

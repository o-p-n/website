ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM lukechannings/deno:v1.30.2 AS builder

WORKDIR /working
RUN mkdir -p /working
COPY . /working
RUN deno task build

FROM docker.io/linuxwolf/serveit:d29ab188f252882553db245bf44a44ea1df103f1 AS website

COPY --from=builder /working/_site /app/web

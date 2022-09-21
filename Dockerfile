ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM node:16.17.0 AS builder

WORKDIR /working
RUN mkdir -p /working

COPY package*.json /working
RUN npm ci

COPY . /working
RUN npx @11ty/eleventy

FROM docker.io/linuxwolf/serveit:8b9558054d041741e7916a16327e78d585768905 AS website

COPY --from=builder /working/_site /app/web

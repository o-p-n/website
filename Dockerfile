ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM node:16.17.0 AS builder

WORKDIR /working
RUN mkdir -p /working

COPY package*.json /working
RUN npm ci

COPY . /working
RUN npx @11ty/eleventy

FROM docker.io/linuxwolf/serveit:37212b3217b28fa943f520e5456bcea0cd7bfb56 AS website

COPY --from=builder /working/_site /app/web

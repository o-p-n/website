ARG DOCKER_REGISTRY=localhost:5000
ARG STAMP=latest
FROM node:16.17.0 AS builder

WORKDIR /working
RUN mkdir -p /working

COPY package*.json /working
RUN npm ci

COPY . /working
RUN npx @11ty/eleventy

FROM nginx:1.22.0 AS website

COPY --from=builder /working/_site /app/web
COPY nginx.conf /etc/nginx/conf.d/default.conf
FROM ghcr.io/o-p-n/serveit@sha256:2bfb516700145a396bbcd5a5756a490588caf44462c949045bbd1c418b8adc28 AS website
LABEL org.opencontainers.image.source="https://github.com/o-p-n/website"

COPY ./_site /app/web

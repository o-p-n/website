FROM ghcr.io/o-p-n/serveit@sha256:0eec49b7787cec7445f25960058204d7e487474cea9c2dffed18e56a51a840c3 AS website
LABEL org.opencontainers.image.source="https://github.com/o-p-n/website"

COPY ./_site /app/web

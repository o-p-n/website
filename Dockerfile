FROM ghcr.io/o-p-n/serveit:2b5e3644cb327217ba33f5695c83ed370b89de29@sha256:89fb4412fb9c587e5b8c9e11adb3cb938c7f5e2cc29bc283fe10aff631c6af0c
LABEL org.opencontainers.image.source="https://github.com/o-p-n/website"

COPY ./_site /app/web

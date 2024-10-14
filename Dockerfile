FROM FROM ghcr.io/o-p-n/serveit:152c4566d68504350b2de8cac2037c98f20125e6@sha256:7522db2851d852a933857d39b3276c088656dc45738bedab158f1514518a9808 AS website
LABEL org.opencontainers.image.source="https://github.com/o-p-n/website"

COPY ./_site /app/web

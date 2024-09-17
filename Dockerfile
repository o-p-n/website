FROM ghcr.io/o-p-n/serveit:98a3584fbf74987cb5e55a22e53266e4b95ac80e@sha256:97f1d2971d6ecfb3d368ff2b4e1bf0a665dd0ea38e3cd7eef43c32b9dfe7e393 AS website
LABEL org.opencontainers.image.source="https://github.com/o-p-n/website"

COPY ./_site /app/web

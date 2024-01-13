FROM ghcr.io/o-p-n/serveit:e5a67a0945337aa4701063fe53826661c2721e41 AS website

COPY ./_site /app/web

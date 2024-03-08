FROM ghcr.io/o-p-n/serveit:e5a67a0945337aa4701063fe53826661c2721e41@sha256:574e0e3449f71e4cf56f713d750533159acfd002bbcff8c26d8bace1fd201fe6 AS website

COPY ./_site /app/web

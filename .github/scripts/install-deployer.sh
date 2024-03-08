#! /usr/bin/env bash

set -xeuo pipefail

PLATFORM_ARCH=$(uname -m)
PLATFORM_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

case ${PLATFORM_ARCH} in
  "amd64")
    PLATFORM_ARCH="x86_64"
    ;;
  "arm64")
    PLATFORM_ARCH="aarch64"
    ;;
esac

case ${PLATFORM_OS} in
  "darwin")
    PLATFORM_OS="apple-darwin"
    ;;
  "linux")
    PLATFORM_OS="unknown-linux-gnu"
    ;;
  *)
    echo "unsupported OS: ${PLATFORM_OS}" > /dev/stderr
    exit 1
    ;;
esac

PLATFORM="${PLATFORM_ARCH}-${PLATFORM_OS}"

pushd /usr/local/bin

gh --repo o-p-n/deployer release download \
    -p "*-${PLATFORM}.tar.gz" -O - \
  | tar xzf -

popd
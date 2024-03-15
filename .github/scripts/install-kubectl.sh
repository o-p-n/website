#! /usr/bin/env bash

set -euo pipefail

loggit() {
  echo "$@" 1>&2
}

INSTALL_PATH="${INSTALL_PATH:-$HOME/bin}"
VERSION="${VERSION:-1.28.3}"

PLATFORM_ARCH=$(uname -m)
PLATFORM_OS="$(uname -s | tr '[:upper:]' '[:lower:]')"


case ${PLATFORM_ARCH} in
  "x86_64")
    PLATFORM_ARCH="amd64"
    ;;
  "aarch64")
    PLATFORM_ARCH="arm64"
    ;;
esac

SHASUM=""
case ${PLATFORM_OS} in
  "darwin")
    SHASUM="shasum -a 256"
    ;;
  "linux")
    SHASUM="sha256sum"
    ;;
esac

PLATFORM="${PLATFORM_OS}/${PLATFORM_ARCH}"

loggit "downloading kubectl ..."
curl -s -LO "https://dl.k8s.io/release/v${VERSION}/bin/${PLATFORM}/kubectl"
curl -s -LO "https://dl.k8s.io/release/v${VERSION}/bin/${PLATFORM}/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | ${SHASUM} --check

loggit "installing kubectl ..."
chmod +x kubectl
mkdir -p "${INSTALL_PATH}"
cp kubectl "${INSTALL_PATH}"
rm -rf kubectl*

loggit "kubectl installed!"

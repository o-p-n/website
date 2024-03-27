#! /bin/bash

set -euo pipefail

loggit() {
  echo "$@" 1>&2
}

INSTALL_PATH="${INSTALL_PATH:-$HOME/bin}"
DEPLOYER_VERSION="${DEPLOYER_VERSION:-0.4.1}"
TASKFILE_VERSION="${TASKFILE_VERSION:-3.35.1}"
CRANE_VERSION="${CRANE_VERSION:-0.19.1}"
KUBECTL_VERSION="${KUBECTL_VERSION:-1.28.3}"

# Platform variables
PLATFORM_ARCH=$(uname -m)
PLATFORM_OS=$(uname -s | tr '[:upper:]' '[:lower:]')

function install_deployer() {
  local version="${DEPLOYER_VERSION}"
  local platform_os="${PLATFORM_OS}"
  local platform_arch="${PLATFORM_ARCH}"

  if [[ "${version}" == "latest" ]] ; then
    version=""
  else
    version="v${version}"
  fi

  case "${platform_os}" in
    "darwin")
      platform_os="apple-darwin"
      ;;
    "linux")
      platform_os="unknown-linux-gnu"
      ;;
  esac

  case "${platform_arch}" in
    "amd64")
      platform_arch="x86_64"
      ;;
    "arm64")
      platform_arch="aarch64"
      ;;
  esac
  platform="${platform_arch}-${platform_os}"

  loggit "downloading o-p-n.deployer ${version:-latest} for ${platform_os}/${platform_arch} ..."

  # TODO verify checksum
  gh --repo o-p-n/deployer release download \
      --pattern "*-${platform}.tar.gz" --clobber \
      --output - ${version} \
    | tar xzf -

  loggit "... installing ..."
  install o-p-n.deployer "${INSTALL_PATH}"
}

function install_taskfile() {
  local version="${TASKFILE_VERSION}"
  local platform_os="${PLATFORM_OS}"
  local platform_arch="${PLATFORM_ARCH}"

  if [[ "${version}" == "latest" ]] ; then
    version=""
  else
    version="v${version}"
  fi

  case "${platform_arch}" in
    "x86_64")
      platform_arch="amd64"
      ;;
    "aarch64")
      platform_arch="arm64"
      ;;
  esac

  loggit "downloading task ${version:-latest} for ${platform_os}/${platform_arch} ..."

  gh --repo go-task/task release download \
      --pattern "task_${platform_os}_${platform_arch}.tar.gz" --clobber \
      --output - ${version} \
    | tar xzf - task

  loggit "... installing ..."
  install task "${INSTALL_PATH}"
}

function install_crane() {
  local version="${CRANE_VERSION}"
  local platform_os="${PLATFORM_OS}"
  local platform_arch="${PLATFORM_ARCH}"

  if [[ "${version}" == "latest" ]] ; then
    version=""
  else
    version="v${version}"
  fi

  case "${platform_os}" in
    "darwin")
      platform_os="Darwin"
      ;;
    "linux")
      platform_os="Linux"
      ;;
  esac
  if [[ "${platform_arch}" == "amd64" ]] ; then
    platform_arch="x86_64"
  fi

  loggit "downloading crane ${version:-latest} for ${platform_os}/${platform_arch} ..."

  # TODO verify checksum
  gh --repo google/go-containerregistry release download \
      --pattern "go-containerregistry_${platform_os}_${platform_arch}.tar.gz" --clobber \
      --output - ${version} \
    | tar xzf - crane

  loggit "... installing ..."
  install crane "${INSTALL_PATH}"
}

function install_kubectl() {
  local version="${KUBECTL_VERSION}"
  local platform_os="${PLATFORM_OS}"
  local platform_arch="${PLATFORM_ARCH}"

  if [[ "${platform_arch}" == "x86_64" ]] ; then
    platform_arch="amd64"
  fi
  if [[ "${platform_arch}" == "aarch64" ]] ; then
    platform_arch="arm64"
  fi

  local platform="${platform_os}/${platform_arch}"

  loggit "downloading kubectl ${version:-latest} for ${platform_os}/${platform_arch} ..."

  # TODO verify checksum
  curl -s -LO "https://dl.k8s.io/release/v${version}/bin/${platform}/kubectl"
  loggit "... installing ..."
  install kubectl "${INSTALL_PATH}"
}

install_deployer
install_taskfile
install_crane
install_kubectl

loggit "... DONE"
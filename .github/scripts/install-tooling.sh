#! /bin/bash

set -euo pipefail

loggit() {
  echo "$@" 1>&2
}

push_it() {
  pushd "$@" > /dev/null
}

pop_it() {
  popd > /dev/null
}

INSTALL_PATH="${INSTALL_PATH:-$HOME/bin}"

CLOUDFLARED_VERSION="${CLOUDFLARED:-2025.6.1}"
DENO_VERSION="${DENO_VERSION:-2.5.2}"
DEPLOYER_VERSION="${DEPLOYER_VERSION:-0.4.1}"
TASKFILE_VERSION="${TASKFILE_VERSION:-3.44.0}"
CRANE_VERSION="${CRANE_VERSION:-0.20.6}"
KUBECTL_VERSION="${KUBECTL_VERSION:-1.32.6}"

# Platform variables
PLATFORM_ARCH=$(uname -m)
PLATFORM_OS=$(uname -s | tr '[:upper:]' '[:lower:]')

function install_cloudflared() {
  local version="${CLOUDFLARED_VERSION}"
  local platform_os="${PLATFORM_OS}"
  local platform_arch="${PLATFORM_ARCH}"
  local compressed=""

  case "${platform_arch}" in
    "x86_64")
      platform_arch="amd64"
      ;;
    "aarch64")
      platform_arch="arm64"
      ;;
  esac

  case "${platform_os}" in
    "darwin")
      compressed=".tgz"
      ;;
  esac

  loggit "downloading cloudflared ${version:-latest} for ${platform_os}/${platform_arch} ..."

  mkdir -p cloudflared && push_it cloudflared

  gh --repo cloudflare/cloudflared release download \
      --pattern "cloudflared-${platform_os}-${platform_arch}${compressed}" --clobber \
      --output "cloudflared${compressed}" ${version}

  if [[ "${compressed}" != "" ]] ; then
    tar xzf "cloudflared${compressed}"
  fi

  loggit "... installing ..."
  install cloudflared "${INSTALL_PATH}"
}

function install_deno() {
  local version="${DENO_VERSION}"
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

  loggit "downloading deno ${version:-latest} for ${platform_os}/${platform_arch} ..."

  mkdir -p deno && push_it deno

  # TODO verify checksum
  gh --repo denoland/deno release download \
      --pattern "deno-${platform}.zip" --clobber \
      --output deno.zip ${version}
  unzip deno.zip

  loggit "... installing ..."
  install deno "${INSTALL_PATH}"

  pop_it
}

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

  mkdir -p o-p-n.deployer && push_it o-p-n.deployer

  # TODO verify checksum
  gh --repo o-p-n/deployer release download \
      --pattern "*-${platform}.tar.gz" --clobber \
      --output o-p-n.deployer.tar.gz ${version}
  tar xzf o-p-n.deployer.tar.gz

  loggit "... installing ..."
  install o-p-n.deployer "${INSTALL_PATH}"

  pop_it
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

  mkdir -p task && push_it task

  gh --repo go-task/task release download \
      --pattern "task_${platform_os}_${platform_arch}.tar.gz" --clobber \
      --output task.tar.gz ${version}
  tar xzf task.tar.gz

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
      --output crane.tar.gz ${version}
  tar xzf crane.tar.gz

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

working_dir=$(mktemp -d)
push_it ${working_dir}

install_cloudflared
install_deno
install_deployer
install_taskfile
install_crane
install_kubectl

pop_it
rm -rf ${working_dir}

loggit "... DONE"

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

UBUNTU_VERSIONS=("20.04" "22.04" "24.04")
ARCHITECTURES=("amd64" "arm64")
OUTPUT_DIR="${PROJECT_ROOT}/dist"
PACKAGE_VERSION=""
PACKAGE_NAME="gento-sdk"
DOCKER_IMAGE_PREFIX="ubuntu"
HOST_UID="$(id -u)"
HOST_GID="$(id -g)"

usage() {
  cat <<'USAGE'
Usage:
  ./SDK_generate_tools/build_all_debs.sh
  ./SDK_generate_tools/build_all_debs.sh --ubuntu 22.04 --arch amd64
  ./SDK_generate_tools/build_all_debs.sh --ubuntu 22.04 --arch arm64 --output-dir dist

Build Gento SDK Debian packages in Docker for Ubuntu/architecture matrices.

Defaults:
  Ubuntu versions: 20.04, 22.04, 24.04
  Architectures:   amd64, arm64
  Output dir:      ./dist

Notes:
  - arm64 builds on amd64 hosts require Docker QEMU/binfmt support.
  - GitHub Actions workflow sets QEMU up automatically.
USAGE
}

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Missing docker. Install Docker or run the GitHub Actions workflow." >&2
    exit 1
  fi
}

docker_platform_for_arch() {
  case "$1" in
    amd64)
      echo "linux/amd64"
      ;;
    arm64)
      echo "linux/arm64/v8"
      ;;
    *)
      echo "Unsupported architecture: $1" >&2
      exit 2
      ;;
  esac
}

run_build() {
  local ubuntu_version="$1"
  local architecture="$2"
  local platform
  local container_output_dir
  local version_arg=()

  platform="$(docker_platform_for_arch "${architecture}")"
  container_output_dir="/out/ubuntu${ubuntu_version}/${architecture}"

  if [[ -n "${PACKAGE_VERSION}" ]]; then
    version_arg=(--package-version "${PACKAGE_VERSION}")
  fi

  echo "============================================"
  echo "Building Ubuntu ${ubuntu_version} ${architecture}"
  echo "============================================"

  docker run --rm \
    --platform "${platform}" \
    -v "${PROJECT_ROOT}:/work" \
    -v "${OUTPUT_DIR}:/out" \
    -w /work \
    "${DOCKER_IMAGE_PREFIX}:${ubuntu_version}" \
    bash -lc "
      set -euo pipefail
      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y --no-install-recommends build-essential dpkg-dev ca-certificates
      ./SDK_generate_tools/generate_sdk.sh \
        --architecture '${architecture}' \
        --package-name '${PACKAGE_NAME}' \
        --output-dir '${container_output_dir}' \
        ${version_arg[*]@Q}
      chown -R '${HOST_UID}:${HOST_GID}' /out /work/SDK_*
    "
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ubuntu|--ubuntu-version)
      UBUNTU_VERSIONS=("$2")
      shift 2
      ;;
    --arch|--architecture)
      ARCHITECTURES=("$2")
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$(mkdir -p "$2" && cd "$2" && pwd)"
      shift 2
      ;;
    --package-name)
      PACKAGE_NAME="$2"
      shift 2
      ;;
    --package-version)
      PACKAGE_VERSION="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_docker
mkdir -p "${OUTPUT_DIR}"

for ubuntu_version in "${UBUNTU_VERSIONS[@]}"; do
  for architecture in "${ARCHITECTURES[@]}"; do
    run_build "${ubuntu_version}" "${architecture}"
  done
done

echo ""
echo "Built packages:"
find "${OUTPUT_DIR}" -type f -name '*.deb' | sort

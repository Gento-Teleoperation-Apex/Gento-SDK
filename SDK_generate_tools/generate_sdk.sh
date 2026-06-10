#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "${SCRIPT_DIR}")" == "SDK_generate_tools" ]]; then
  PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
else
  PROJECT_ROOT="${SCRIPT_DIR}"
fi
DEFAULT_COMPILE_SCRIPT=""
PREFIX="/usr/local"
SDK_ROOT=""
COMPILE_SCRIPT=""
AUTO_COMPILE=1
MODE="package"
OUTPUT_DIR="${PROJECT_ROOT}"
PACKAGE_NAME="gento-sdk"
PACKAGE_VERSION=""
PACKAGE_VERSION_SET=0
MAINTAINER="Gento <support@gento.local>"
ARCHITECTURE=""

usage() {
  cat <<'USAGE'
Usage:
  ./SDK_generate_tools/generate_sdk.sh [--prefix /usr/local] [--sdk-root /path/to/C_SDK] [--output-dir .]
  ./SDK_generate_tools/generate_sdk.sh --install [--prefix /usr/local] [--sdk-root /path/to/C_SDK]
  ./SDK_generate_tools/generate_sdk.sh --version [--prefix /usr/local]

Runs linux_auto_compile.sh first, then builds a Debian package for Gento SDK
headers and libGentoSDK.so on Ubuntu.

Defaults:
  --prefix          /usr/local
  --sdk-root        auto-detected */linux_auto_compile.sh sibling C_SDK
  --compile-script  auto-detected linux_auto_compile.sh
  --output-dir      project root directory
  --package-name    gento-sdk
  --package-version auto-detected from C_SDK/Common/FXCommon.h

After package install:
  sudo apt install ./gento-sdk_4.4.0_amd64.deb
  gento-sdk-version
  colcon build --packages-select marvin_ros_control

CMake override examples:
  colcon build --cmake-args -DGENTO_SDK_ROOT=/usr/local
  GENTO_SDK_ROOT=/opt/gentosdk colcon build --packages-select marvin_ros_control

Legacy direct install:
  ./SDK_generate_tools/generate_sdk.sh --install
USAGE
}

find_default_compile_script() {
  local match
  match="$(find "${PROJECT_ROOT}" -path '*/SDK/*/linux_auto_compile.sh' -type f | sort | head -n 1)"
  if [[ -n "${match}" ]]; then
    echo "${match}"
    return
  fi

  match="$(find "${PROJECT_ROOT}" -name linux_auto_compile.sh -type f | sort | head -n 1)"
  if [[ -n "${match}" ]]; then
    echo "${match}"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      PREFIX="$2"
      shift 2
      ;;
    --sdk-root)
      SDK_ROOT="$(cd "$2" && pwd)"
      shift 2
      ;;
    --compile-script)
      COMPILE_SCRIPT="$(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
      shift 2
      ;;
    --no-compile)
      AUTO_COMPILE=0
      shift
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
      PACKAGE_VERSION_SET=1
      shift 2
      ;;
    --maintainer)
      MAINTAINER="$2"
      shift 2
      ;;
    --architecture)
      ARCHITECTURE="$2"
      shift 2
      ;;
    --install)
      MODE="install"
      shift
      ;;
    --version)
      MODE="version"
      shift
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

DEFAULT_COMPILE_SCRIPT="$(find_default_compile_script)"
if [[ -z "${COMPILE_SCRIPT}" ]]; then
  COMPILE_SCRIPT="${DEFAULT_COMPILE_SCRIPT}"
fi

if [[ -z "${SDK_ROOT}" ]]; then
  if [[ -n "${COMPILE_SCRIPT}" && -d "$(dirname "${COMPILE_SCRIPT}")/C_SDK" ]]; then
    SDK_ROOT="$(cd "$(dirname "${COMPILE_SCRIPT}")/C_SDK" && pwd)"
  else
    SDK_ROOT="${PROJECT_ROOT}"
  fi
fi

SDK_LIB_SRC="${SDK_ROOT}/libGentoSDK.so"
DEST_INCLUDE="${PREFIX}/include/gentosdk"
DEST_LIB_DIR="${PREFIX}/lib"
DEST_LIB="${DEST_LIB_DIR}/libGentoSDK.so"
DEST_BIN_DIR="${PREFIX}/bin"
DEST_VERSION_TOOL="${DEST_BIN_DIR}/gento-sdk-version"

SUDO=()

configure_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    SUDO=()
    return
  fi

  if [[ -d "${PREFIX}" && -w "${PREFIX}" ]]; then
    SUDO=()
    return
  fi

  if [[ ! -e "${PREFIX}" && -w "$(dirname "${PREFIX}")" ]]; then
    SUDO=()
    return
  fi

  SUDO=(sudo)
}

require_sources() {
  if [[ ! -f "${SDK_LIB_SRC}" ]]; then
    echo "Missing SDK library: ${SDK_LIB_SRC}" >&2
    exit 1
  fi

  if [[ ! -f "${SDK_ROOT}/L1Robot/L1Robot.h" ]]; then
    echo "Missing SDK headers under: ${SDK_ROOT}" >&2
    exit 1
  fi
}

detect_package_version() {
  local version_header="${SDK_ROOT}/Common/FXCommon.h"
  local major
  local minor
  local patch

  if [[ -f "${version_header}" ]]; then
    major="$(awk '/#define[[:space:]]+FX_SDK_MAJOR_VERSION/ { gsub(/[^0-9]/, "", $3); print $3; exit }' "${version_header}")"
    minor="$(awk '/#define[[:space:]]+FX_SDK_MINOR_VERSION/ { gsub(/[^0-9]/, "", $3); print $3; exit }' "${version_header}")"
    patch="$(awk '/#define[[:space:]]+FX_SDK_PATCH_VERSION/ { gsub(/[^0-9]/, "", $3); print $3; exit }' "${version_header}")"

    if [[ -n "${major}" && -n "${minor}" && -n "${patch}" ]]; then
      echo "${major}.${minor}.${patch}"
      return
    fi
  fi

  if [[ "${SDK_ROOT}" =~ /SDK/([0-9]{8})/C_SDK$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return
  fi

  echo "1.0.0"
}

run_linux_auto_compile() {
  if [[ "${AUTO_COMPILE}" -eq 0 ]]; then
    return
  fi

  if [[ -z "${COMPILE_SCRIPT}" ]]; then
    echo "Missing linux_auto_compile.sh. Use --compile-script /path/to/linux_auto_compile.sh or --no-compile." >&2
    exit 1
  fi

  if [[ ! -f "${COMPILE_SCRIPT}" ]]; then
    echo "Missing linux_auto_compile.sh: ${COMPILE_SCRIPT}" >&2
    exit 1
  fi

  if ! command -v g++ >/dev/null 2>&1; then
    echo "Missing g++. Install a compiler first: sudo apt install build-essential" >&2
    exit 1
  fi

  echo "Running Linux auto compile: ${COMPILE_SCRIPT}"
  bash "${COMPILE_SCRIPT}"
}

install_headers() {
  local dest_include="$1"
  local header
  local relative
  local target

  while IFS= read -r header; do
    relative="${header#${SDK_ROOT}/}"
    target="${dest_include}/${relative}"
    "${SUDO[@]}" install -d "$(dirname "${target}")"
    "${SUDO[@]}" install -m 0644 "${header}" "${target}"
  done < <(find "${SDK_ROOT}" -type f -name '*.h' | sort)
}

write_version_source() {
  local output="$1"
  cat > "${output}" <<'CPP'
#include <iostream>
#include "L1Robot.h"

int main()
{
    const int version = FX_L1_System_GetSDKVersion();
    std::cout << "Gento SDK version: " << version << std::endl;
    return 0;
}
CPP
}

build_version_tool() {
  local output="$1"
  local include_root="${2:-${DEST_INCLUDE}}"
  local lib_dir="${3:-${DEST_LIB_DIR}}"
  local tmpdir
  tmpdir="$(mktemp -d)"

  write_version_source "${tmpdir}/gento_sdk_version.cpp"
  g++ -std=c++17 -DCMPL_LIN "${tmpdir}/gento_sdk_version.cpp" \
    -I"${include_root}/Common" \
    -I"${include_root}/L1Robot" \
    -I"${include_root}/L0Control" \
    -I"${include_root}/Kinematics" \
    -I"${include_root}/Kinematics/ArmKinematics" \
    -I"${include_root}/Kinematics/BaseMath" \
    -I"${include_root}/Kinematics/DynaIdent" \
    -I"${include_root}/Kinematics/KineCommon" \
    -I"${include_root}/Kinematics/MotionPlanner" \
    -I"${include_root}/Kinematics/SkyeBodyKinematics" \
    -L"${lib_dir}" \
    -Wl,-rpath,"${DEST_LIB_DIR}" \
    -lGentoSDK \
    -o "${output}"
  rm -rf "${tmpdir}"
}

print_version() {
  if [[ -x "${DEST_VERSION_TOOL}" ]]; then
    "${DEST_VERSION_TOOL}"
    return
  fi

  echo "Version tool is not installed: ${DEST_VERSION_TOOL}" >&2
  echo "Run install first: ./SDK_generate_tools/generate_sdk.sh --prefix ${PREFIX}" >&2
  exit 1
}

install_sdk() {
  run_linux_auto_compile
  require_sources
  configure_sudo

  echo "Installing Gento SDK to ${PREFIX}"
  "${SUDO[@]}" install -d "${DEST_INCLUDE}" "${DEST_LIB_DIR}" "${DEST_BIN_DIR}"
  install_headers "${DEST_INCLUDE}"
  "${SUDO[@]}" install -m 0644 "${SDK_LIB_SRC}" "${DEST_LIB}"

  local tmp_tool
  tmp_tool="$(mktemp)"
  build_version_tool "${tmp_tool}"
  "${SUDO[@]}" install -m 0755 "${tmp_tool}" "${DEST_VERSION_TOOL}"
  rm -f "${tmp_tool}"

  if command -v ldconfig >/dev/null 2>&1 && \
    [[ "${DEST_LIB_DIR}" == "/usr/local/lib" || "${DEST_LIB_DIR}" == "/usr/lib" || "${DEST_LIB_DIR}" == /usr/lib/* ]]; then
    "${SUDO[@]}" ldconfig
  fi

  echo "Installed:"
  echo "  headers: ${DEST_INCLUDE}"
  echo "  library: ${DEST_LIB}"
  echo "  version: ${DEST_VERSION_TOOL}"
  "${DEST_VERSION_TOOL}"
}

detect_architecture() {
  if [[ -n "${ARCHITECTURE}" ]]; then
    echo "${ARCHITECTURE}"
    return
  fi

  if command -v dpkg >/dev/null 2>&1; then
    dpkg --print-architecture
    return
  fi

  case "$(uname -m)" in
    x86_64)
      echo "amd64"
      ;;
    aarch64|arm64)
      echo "arm64"
      ;;
    armv7l)
      echo "armhf"
      ;;
    *)
      echo "all"
      ;;
  esac
}

package_installed_size_kb() {
  local package_root="$1"
  du -sk "${package_root}" | awk '{print $1}'
}

write_control_file() {
  local debian_dir="$1"
  local package_root="$2"
  local architecture="$3"
  local installed_size
  installed_size="$(package_installed_size_kb "${package_root}")"

  cat > "${debian_dir}/control" <<CONTROL
Package: ${PACKAGE_NAME}
Version: ${PACKAGE_VERSION}
Section: libs
Priority: optional
Architecture: ${architecture}
Maintainer: ${MAINTAINER}
Installed-Size: ${installed_size}
Description: Gento C SDK runtime library and headers
 Provides libGentoSDK.so, C/C++ SDK headers, and the gento-sdk-version helper.
CONTROL
}

write_maintainer_scripts() {
  local debian_dir="$1"

  cat > "${debian_dir}/postinst" <<'POSTINST'
#!/bin/sh
set -e

if command -v ldconfig >/dev/null 2>&1; then
  ldconfig
fi

exit 0
POSTINST

  cat > "${debian_dir}/postrm" <<'POSTRM'
#!/bin/sh
set -e

if command -v ldconfig >/dev/null 2>&1; then
  ldconfig
fi

exit 0
POSTRM

  chmod 0755 "${debian_dir}/postinst" "${debian_dir}/postrm"
}

build_deb_package() {
  run_linux_auto_compile
  require_sources

  if ! command -v dpkg-deb >/dev/null 2>&1; then
    echo "Missing dpkg-deb. Install dpkg-dev first: sudo apt install dpkg-dev" >&2
    exit 1
  fi

  if ! command -v g++ >/dev/null 2>&1; then
    echo "Missing g++. Install a compiler first: sudo apt install build-essential" >&2
    exit 1
  fi

  local architecture
  local package_root
  local debian_dir
  local staged_prefix
  local staged_include
  local staged_lib_dir
  local staged_bin_dir
  local package_file

  architecture="$(detect_architecture)"
  package_root="$(mktemp -d)"
  chmod 0755 "${package_root}"
  debian_dir="${package_root}/DEBIAN"
  staged_prefix="${package_root}${PREFIX}"
  staged_include="${staged_prefix}/include/gentosdk"
  staged_lib_dir="${staged_prefix}/lib"
  staged_bin_dir="${staged_prefix}/bin"
  package_file="${OUTPUT_DIR}/${PACKAGE_NAME}_${PACKAGE_VERSION}_${architecture}.deb"

  mkdir -p "${OUTPUT_DIR}"
  install -d -m 0755 "${debian_dir}" "${staged_include}" "${staged_lib_dir}" "${staged_bin_dir}"
  SUDO=()

  install_headers "${staged_include}"
  install -m 0644 "${SDK_LIB_SRC}" "${staged_lib_dir}/libGentoSDK.so"
  build_version_tool "${staged_bin_dir}/gento-sdk-version" "${staged_include}" "${staged_lib_dir}"
  chmod 0755 "${staged_bin_dir}/gento-sdk-version"

  write_control_file "${debian_dir}" "${package_root}" "${architecture}"
  write_maintainer_scripts "${debian_dir}"

  dpkg-deb --build --root-owner-group "${package_root}" "${package_file}"
  rm -rf "${package_root}"

  echo "Built Debian package: ${package_file}"
  echo "Install with:"
  echo "  sudo apt install ${package_file}"
}

if [[ "${PACKAGE_VERSION_SET}" -eq 0 ]]; then
  PACKAGE_VERSION="$(detect_package_version)"
fi

case "${MODE}" in
  package)
    build_deb_package
    ;;
  install)
    install_sdk
    ;;
  version)
    print_version
    ;;
esac

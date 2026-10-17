#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.0"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"
FLUTTER_SHA256="26cd99d3d94b1367e6b50535a18aeef0282c10a535bbe3ec493534dcdab75296"
CACHE_ROOT="${FLUTTER_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/bms-flutter}"
SDK_DIR="${CACHE_ROOT}/flutter-${FLUTTER_VERSION}"

mkdir -p "$CACHE_ROOT"
exec 9>"${CACHE_ROOT}/.install.lock"
flock 9
if [[ ! -x "$SDK_DIR/bin/flutter" ]]; then
  rm -rf "$SDK_DIR"
  work_dir="$(mktemp -d "${CACHE_ROOT}/.install.XXXXXX")"
  trap 'rm -rf "$work_dir"' EXIT
  archive_path="${work_dir}/${FLUTTER_ARCHIVE}"
  curl --fail --location --retry 3 --retry-delay 2 --output "$archive_path" "$FLUTTER_URL"
  echo "${FLUTTER_SHA256}  ${archive_path}" | sha256sum --check --status
  tar -xJf "$archive_path" -C "$work_dir"
  mv "${work_dir}/flutter" "$SDK_DIR"
fi

# Vercel may restore the shared cache with ownership different from the build
# user. Flutter invokes Git internally, so explicitly trust this pinned SDK.
git config --global --add safe.directory "$SDK_DIR" 2>/dev/null || true
"${SDK_DIR}/bin/flutter" --version >/dev/null
"${SDK_DIR}/bin/flutter" config --no-analytics --enable-web >/dev/null
"${SDK_DIR}/bin/flutter" precache --web >/dev/null
printf '%s\n' "${SDK_DIR}/bin/flutter"

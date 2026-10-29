#!/usr/bin/env bash
set -euo pipefail

FLUTTER_BIN="$(bash scripts/bootstrap_flutter.sh)"
export PATH="$(dirname "$FLUTTER_BIN"):$PATH"
export CI=true

flutter pub get
flutter analyze
flutter test
DART_DEFINES=()
if [[ -n "${BMS_GATEWAY_WS_URL:-}" ]]; then
  DART_DEFINES+=("--dart-define=BMS_GATEWAY_WS_URL=${BMS_GATEWAY_WS_URL}")
fi
flutter build web --release "${DART_DEFINES[@]}"

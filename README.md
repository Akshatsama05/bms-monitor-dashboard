# BMS Monitor Dashboard

A responsive Flutter Web dashboard prototype for read-only battery-management-system monitoring. It is designed for landscape industrial/tablet displays and reflows for mobile browsers.

> **Safety boundary:** The application starts in clearly labeled simulated-data mode and does not control battery hardware. A real gateway must not be connected until its protocol, authentication, thresholds, and operational safety review are approved.

## Project status

This repository is ready for UI review, simulated demonstrations, GitHub review, and managed container deployment. It is not a production-certified battery-monitoring or battery-control system.

Implemented defensive behavior includes strict live-packet validation, bounded WebSocket payloads, secure `wss://` enforcement for HTTPS browser sessions, bounded reconnects, stale-data detection, last-live-reading preservation after disconnect, dynamic gateway identity, and local prototype alerts for low SOC, low SOH, high temperature, and stale telemetry.

## Requirements

- Flutter **3.47.0 stable**. The pinned SDK is downloaded and SHA-256 verified by `scripts/bootstrap_flutter.sh`.
- Bash, `curl`, `tar`, `xz`, `sha256sum`, and Git.
- Chrome/Chromium for interactive local preview.

## Quick start

```bash
FLUTTER_BIN="$(bash scripts/bootstrap_flutter.sh)"
export PATH="$(dirname "$FLUTTER_BIN"):$PATH"
flutter pub get
flutter analyze
flutter test
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
```

For a release build:

```bash
flutter build web --release
```

The static output is written to `build/web`. The route manifest is available at `/manus-routes.json`.

## Demo mode

With no gateway URL configured, the dashboard uses sample telemetry and labels it as simulated/demo data. Settings can trigger a simulated warning for interface review. Demo mode never sends commands to a physical battery.

## Authentication

The app opens behind a custom BMS Monitor authentication screen with no third-party product branding. Firebase Authentication provides Email/Password sign-in, account creation, Google Sign-In, email verification, password reset, and logout. The Flutter router renders the dashboard only after Firebase returns a verified authenticated user; unverified email-password accounts remain on the verification screen.

The Firebase Web configuration is stored in `lib/firebase_options.dart`. These client configuration values are intended for frontend use; never add a Firebase service-account key or Admin SDK private key to this repository. Add the Vercel deployment hostname to Firebase Authentication's Authorized domains and enable Email/Password plus Google providers in the Firebase Console.

## Gateway boundary

A browser-accessible WebSocket can be supplied at build/run time:

```bash
flutter run -d chrome \
  --dart-define=BMS_GATEWAY_WS_URL=wss://gateway.example/telemetry
```

The current adapter accepts a validated JSON snapshot shaped like the example in [`docs/GATEWAY-INTEGRATION.md`](docs/GATEWAY-INTEGRATION.md). It does not implement a gateway server-side proxy, MQTT, CAN, Modbus, command handling, or historical persistence.

Never place private credentials in a Flutter Web `--dart-define` or frontend environment variable. Values compiled into browser JavaScript are public.

## Validation and build

Run the same checks used by the Vercel build:

```bash
bash scripts/vercel_build.sh
```

That script installs the pinned Flutter SDK, runs dependency resolution, static analysis, all tests, and a release Web build.

## Deployment

- GitHub/Vercel instructions: [`DEPLOYMENT.md`](DEPLOYMENT.md)
- Build entrypoint: [`scripts/vercel_build.sh`](scripts/vercel_build.sh)
- SDK bootstrap: [`scripts/bootstrap_flutter.sh`](scripts/bootstrap_flutter.sh)

The repository intentionally excludes `.dart_tool/`, `build/`, coverage output, local environment files, and secrets. Vercel builds the static site from source.

## Documentation map

- [`docs/PROJECT-STRUCTURE.md`](docs/PROJECT-STRUCTURE.md) — folder and file responsibilities.
- [`docs/SRS.md`](docs/SRS.md) — formal software requirements specification and acceptance evidence.
- [`docs/SDLC-MODEL-REPORT.md`](docs/SDLC-MODEL-REPORT.md) — selected lifecycle, gates, traceability, and definition of done.
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — current data flow and recommended production boundary.
- [`docs/GATEWAY-INTEGRATION.md`](docs/GATEWAY-INTEGRATION.md) — telemetry contract and integration steps.
- [`docs/SECURITY.md`](docs/SECURITY.md) — security boundary, threat notes, and prohibited assumptions.
- [`docs/KNOWN-LIMITATIONS.md`](docs/KNOWN-LIMITATIONS.md) — explicit prototype limitations and ownership.
- [`docs/RELEASE-CHECKLIST.md`](docs/RELEASE-CHECKLIST.md) — review and deployment checklist.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — development and review workflow.
- [`TODO.md`](TODO.md) — delivery status and remaining external work.

## License and ownership

No open-source license is declared in this repository. Add the company-approved license and ownership notice before public redistribution.

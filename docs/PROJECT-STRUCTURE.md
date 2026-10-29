# Project Structure

This document explains the purpose of every source directory and important root file.

## Root files

| Path | Responsibility |
|---|---|
| `README.md` | Entry point: status, setup, boundaries, validation, and documentation links. |
| `DEPLOYMENT.md` | GitHub and Vercel handoff instructions. |
| `TODO.md` | Delivery requirements, evidence, and unresolved external integration work. |
| `plan.md` | Original product/design plan and interaction decisions. |
| `pubspec.yaml` | Flutter package metadata and runtime dependencies. |
| `pubspec.lock` | Reproducible resolved Dart package versions. |
| `.flutter-version` | Pinned Flutter release identifier. |
| `.gitignore` | Excludes SDK artifacts, build output, caches, secrets, and local files. |
| `vercel.json` | Static Vercel build command, output directory, and response headers. |
| `app.config.ts` | Project-logo metadata; it is not required by Vercel runtime. |
| `CONTRIBUTING.md` | Local development, checks, and change-review rules. |

## `lib/`

Application source code.

| Path | Responsibility |
|---|---|
| `lib/main.dart` | Flutter application entrypoint. |
| `lib/app.dart` | Root app widget, provider registration, theme, and navigation shell. |
| `lib/models/` | Typed telemetry, cell readings, events, alerts, validation, and safety-derived alerts. |
| `lib/data/` | Deterministic demo telemetry used only when no live endpoint is configured. |
| `lib/services/` | Firebase authentication, provider lifecycle/state management, and the browser WebSocket adapter. |
| `lib/firebase_options.dart` | Firebase Web App client configuration. |
| `lib/theme/` | Design tokens, colors, typography, and application theme. |
| `lib/views/` | Overview and secondary screen compositions: faults, trends, cells, and settings. |
| `lib/widgets/` | Reusable header, navigation, cards, panels, indicators, and chart painters. |

## `test/`

Automated unit and widget tests. Tests cover telemetry parsing/order, strict validation, derived safety alerts, navigation, simulated warning behavior, and invalid gateway fallback.

## `web/`

Flutter Web host assets.

| Path | Responsibility |
|---|---|
| `web/index.html` | Browser document shell and metadata. |
| `web/bms-mark.svg` | Application mark used by the browser shell. |
| `web/manus-routes.json` | Declared page route manifest for platform/deployment tooling. |

## `scripts/`

| Path | Responsibility |
|---|---|
| `scripts/bootstrap_flutter.sh` | Downloads the pinned Linux Flutter SDK, verifies SHA-256, handles cache locking, and registers Git safe-directory ownership for CI caches. |
| `scripts/vercel_build.sh` | Runs dependency installation, analysis, tests, and the release Web build. |

## Intentionally excluded from the review ZIP

`.dart_tool/`, `build/`, Flutter SDK caches, coverage files, Vercel caches, local `.env` files, credentials, and generated logs are not source deliverables. They are recreated by the documented build process.

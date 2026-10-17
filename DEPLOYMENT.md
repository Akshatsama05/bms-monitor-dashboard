# Deployment handoff

## GitHub

Create or open the target GitHub repository, then upload the contents of this project. Do not upload `.dart_tool/`, private credentials, or gateway secrets. The important deployment files are:

- `pubspec.yaml` and `pubspec.lock`
- `lib/`
- `test/`
- `web/`
- `scripts/bootstrap_flutter.sh`
- `scripts/vercel_build.sh`
- `vercel.json`
- `README.md`

## Vercel

1. In Vercel, choose **Add New → Project**.
2. Import the GitHub repository.
3. Keep the repository root as the project root.
4. Use the settings already committed in `vercel.json`:
   - Framework preset: Other
   - Install command: `true`
   - Build command: `bash scripts/vercel_build.sh`
   - Output directory: `build/web`
5. Deploy.

The build script installs the pinned Flutter 3.47.0 SDK, runs `flutter pub get`, `flutter analyze`, all Flutter tests, and `flutter build web --release`.

If a browser-safe gateway endpoint is later approved, add `BMS_GATEWAY_WS_URL` as a Vercel environment variable. Do not place private credentials in this variable or in the Flutter Web bundle.

## Current verification

- Flutter tests: 9 passing
- `flutter analyze`: clean
- Flutter Web release build: successful
- `manus-routes.json`: valid and served from the build output

The live gateway adapter rejects incomplete or out-of-range packets, caps message size and collection sizes, requires `wss://` from HTTPS browser sessions, preserves the last live reading when disconnected, and raises local low-SOC, low-SOH, high-temperature, and stale-data alerts. These are defensive safeguards, not a substitute for gateway authentication or battery safety certification.

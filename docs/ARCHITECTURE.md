# System Architecture

## 1. Context

BMS Monitor is a read-only Flutter Web application for reviewing battery-management-system telemetry. The deployed website is a static Vercel application. Firebase Authentication provides the identity layer; no password or authentication secret is implemented in the Flutter UI.

## 2. Authentication flow

```text
Browser
  |
  v
Vercel static Flutter Web build
  |
  v
Firebase Auth SDK
  |                    \
  | Email/Password       \ Google Sign-In popup
  | email verification    \
  v                        v
Firebase Authentication identity
  |
  v
AuthController
  |
  +-- signed out/error/verification required --> AuthView
  |
  +-- verified authenticated user -----------> BmsDashboardShell
```

`AuthController` owns loading, signed-out, email-verification, authenticated, and error states. Email/password accounts must verify their email before the dashboard is rendered. Google users are accepted after Firebase completes the provider sign-in. The browser stores Firebase's managed session; the application does not store passwords or tokens in local storage.

## 3. Flutter application flow

```text
Firebase.initializeApp(DefaultFirebaseOptions.web)
                    |
                    v
              AuthController
                    |
                    +--> AuthView
                    |      +--> Sign in
                    |      +--> Create account
                    |      +--> Google Sign-In
                    |      +--> Forgot password
                    |      +--> Verify email
                    |
                    +--> BmsDashboardShell
                           +--> Overview
                           +--> Faults
                           +--> Trends
                           +--> Cells
                           +--> Settings
```

The dashboard router does not render protected content while authentication is unknown or unauthenticated. Logout calls Firebase `signOut()` and returns to the custom BMS Monitor sign-in screen.

## 4. Telemetry flow

```text
Simulated source or browser WebSocket
              |
              v
BmsGatewayClient
  URL/message/size validation
              |
              v
BmsTelemetry.tryFromJson
  schema/range/collection validation
              |
              v
BmsDashboardProvider
  lifecycle, stale state, derived alerts
              |
              v
Flutter views and reusable widgets
```

The default source is clearly labeled simulated data. A configured browser WebSocket is an opt-in adapter and is not a substitute for a production gateway proxy. The browser adapter requires `wss://` in HTTPS contexts, bounds payload size and collections, rejects invalid readings, and preserves the last valid reading while marking the connection stale.

## 5. Trust boundaries

- Firebase owns credential handling, identity, password reset, email verification, Google federation, and session persistence.
- The Firebase Web config in `lib/firebase_options.dart` contains public client identifiers only. Firebase service-account credentials and Admin SDK private keys must never enter the Flutter Web build.
- The browser must not hold private gateway credentials or connect directly to a private battery network for live production use.
- A future backend gateway should own device identity, schema versioning, rate limits, thresholds, audit logs, and historical storage.
- The UI is read-only and deliberately exposes no contactor, charging, discharging, reset, or configuration command.

## 6. Deployment components

- `scripts/bootstrap_flutter.sh` installs the pinned Flutter SDK and verifies its checksum.
- `scripts/vercel_build.sh` runs dependency resolution, analysis, tests, and the release Web build.
- `vercel.json` declares the static Vercel build and security headers.
- `lib/firebase_options.dart` configures the Firebase Web app.
- `web/manus-routes.json` declares the single application page route for deployment tooling; it does not provide authentication or application branding.

## 7. Recommended future live architecture

```text
Battery/BMS
    |
    v
Private protocol adapter (MQTT/CAN/Modbus/REST/WebSocket)
    |
    v
Authenticated gateway service
    |                 \
    v                  v
Time-series database  Alert/notification service
    |
    v
Authenticated API/WebSocket
    |
    v
Flutter Web dashboard
```

The future gateway service should own device identity, schema versioning, rate limits, threshold configuration, audit logging, and durable storage. This repository intentionally stops at the read-only dashboard and validated browser adapter.

## 8. Deliberate non-goals

The project does not implement charging, discharging, contactor, reset, configuration, or other battery-control commands. It is not a certified safety instrument or a replacement for a BMS protection system.

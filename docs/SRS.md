# Software Requirements Specification

## 1. Document control

| Field | Value |
|---|---|
| Product | BMS Monitor Dashboard |
| Version | 1.0 |
| Status | Prototype release specification |
| Primary platform | Flutter Web served by a managed container |
| Authentication | Firebase Authentication with Email/Password and Google providers |
| Audience | Operators, reviewers, developers, and deployment owners |

## 2. Purpose

BMS Monitor provides a read-only operational view of battery-management-system telemetry. The interface is intended to help an operator understand pack state, health, faults, trends, cells, and recent events from a desktop, tablet, or mobile browser. It is not a battery controller, protection relay, or certified safety instrument.

## 3. Scope

The release includes a responsive custom login gate, Firebase Email/Password and Google authentication, email verification, password reset, a protected Flutter dashboard, clearly labeled simulated telemetry, an optional validated browser WebSocket adapter, fault/event/trend/cell/settings views, logout, automated checks, and static Vercel deployment.

The release does not include battery-control commands, MQTT/CAN/Modbus protocol adapters, a production gateway proxy, historical persistence, alert escalation, or certification evidence.

## 4. Actors

- **Operator:** Authenticated user who views read-only telemetry and dashboard summaries.
- **Reviewer:** Stakeholder who checks the visual system, responsive behavior, and documented safety boundary.
- **Maintainer:** Developer who changes source, runs checks, and reviews commits.
- **Deployment owner:** Authorized owner who configures Firebase provider settings, Authorized domains, GitHub, and Vercel deployment settings.

## 5. Functional requirements

### FR-01 Authentication entry

The application shall display the BMS Monitor sign-in screen before rendering dashboard content to an unauthenticated browser.

### FR-02 Firebase authentication

The application shall support Firebase Email/Password sign-in and Google Sign-In through the Firebase Web SDK. The application shall not implement or display a third-party platform login brand in the BMS Monitor login screen.

### FR-03 Session validation

The Flutter application shall initialize Firebase before rendering the auth router and shall render the dashboard only when Firebase returns an authenticated user. Email/password users shall be required to verify their email before entry.

### FR-04 Authentication failure

The application shall remain on the sign-in screen when credentials are invalid, Google sign-in is cancelled, Firebase configuration is unavailable, password reset fails, or the session cannot be validated. It shall show a concise actionable error without exposing tokens or secrets.

### FR-05 Logout

The logout action shall call the server logout endpoint, clear the application session cookie, and return the user to the sign-in screen.

### FR-06 Dashboard navigation

After authentication, the application shall provide Overview, Faults, Trends, Cells, and Settings views through persistent navigation.

### FR-07 Telemetry display

The Overview shall display pack SOC, SOH, voltage, current, power, energy, capacity, cycle count, operating mode, temperature range, gateway identity, and data freshness using consistent units.

### FR-08 Telemetry source boundary

Without an approved gateway endpoint, the application shall use visibly labeled simulated data. If a WebSocket endpoint is configured, the adapter shall require a secure `wss://` URL for HTTPS deployment and validate incoming JSON before updating dashboard state.

### FR-09 Defensive validation

The telemetry boundary shall reject oversized messages, missing required fields, invalid ranges, impossible temperature ordering, invalid operating modes, and excessive collection sizes. Invalid input shall not reach dashboard state.

### FR-10 Faults, events, trends, and cells

The application shall present fault severity, recent events, illustrative time ranges, and cell-level information where sample or validated telemetry provides those values. It shall make simulated or unavailable data explicit.

### FR-11 Read-only safety boundary

The UI shall not expose controls for contactors, charging, discharging, reset, configuration, alarm-limit changes, or other battery-control actions.

## 6. Nonfunctional requirements

- **NFR-01 Responsive:** Usable at wide landscape, tablet, and narrow mobile widths.
- **NFR-02 Security:** OAuth exchange and session signing occur server-side; secrets are not embedded in Flutter Web output.
- **NFR-03 Cookie compatibility:** Published and embedded HTTPS sessions use `SameSite=None; Secure` application cookies.
- **NFR-04 Availability:** The container shall answer `/_app/health` without authentication and serve the Flutter output on the configured port.
- **NFR-05 Maintainability:** Source is organized by models, services, views, widgets, theme, tests, and deployment files.
- **NFR-06 Verification:** Every release candidate shall pass `flutter analyze`, Flutter tests, and `flutter build web --release`.
- **NFR-07 Traceability:** Requirements, architecture, tests, release checks, and SDLC decisions shall be documented in the repository.
- **NFR-08 Safety:** The application shall clearly distinguish sample telemetry from a live gateway and shall not claim physical connectivity without validated input.

## 7. Acceptance evidence

| Requirement area | Evidence |
|---|---|
| Auth gate and router | `lib/services/auth_controller.dart`, `lib/app.dart`, `lib/views/auth_view.dart` |
| Firebase configuration | `lib/firebase_options.dart`, Firebase Console provider settings |
| Telemetry validation | `lib/models/`, `lib/services/gateway_client.dart`, unit tests |
| Responsive dashboard | Flutter widget tests and desktop/mobile review |
| Build and tests | `scripts/vercel_build.sh`, Flutter analysis and test results |
| Deployment readiness | Vercel build output, `/manus-routes.json`, Firebase Authorized domains |

## 8. Open production decisions

A real gateway integration still requires the device protocol, schema/version, device identity, gateway authentication, approved alarm thresholds, TLS policy, retention requirements, operational owner, security review, monitoring, backup/recovery, and acceptance testing. These decisions must be approved before live telemetry or safety-critical use.

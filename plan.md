# BMS Monitor Dashboard — SDLC and Implementation Plan

## Project status and scope

The website workspace is initialized and the Flutter Web prototype has been implemented in small Agile increments. Current evidence: `flutter analyze` is clean, all five unit/widget tests pass, the final Flutter Web release build succeeds, both local and public Preview return HTTP 200 including the JSON route manifest, and a 14 MB source-plus-build ZIP passes integrity checking. GitHub/Vercel authorization and external deployment confirmation remain open delivery steps. This plan uses the requirements document as the functional baseline, the supplied dashboard screenshot as a visual reference (not an asset or design to copy), and the handwritten SDLC note as a process reference.

The deliverable is a responsive, interactive BMS monitoring **prototype** for landscape industrial/tablet displays and mobile screens. Gateway readings will be clearly identified as simulated sample data until a real gateway endpoint, protocol details, and access credentials are provided. The prototype will demonstrate the required dashboard and navigation without claiming that a battery system is connected or using this interface for battery control.

## Selected SDLC model

Use **Agile as the primary delivery lifecycle**, with requirement-linked verification and DevOps release practices as supporting disciplines:

- **Agile/incremental delivery** is the team's primary model: implement the dashboard in small coherent increments, review outcomes regularly, and incorporate visual, interaction, and device feedback without waiting for a large final build.
- **V-model-inspired verification** is a supporting quality practice, not a competing delivery model: trace each requirement group to an appropriate verification layer. This is proportionate prototype assurance, not certification or validation of a live battery-control system.
- **DevOps release practices** support Agile delivery through source review, repeatable builds, and Vercel deployment. A GitHub/Vercel account connection and owner confirmation may be required before external repository or deployment changes.

A Waterfall sequence would make design and feedback changes slow. Agile remains the delivery model; requirement-to-test traceability and explicit review/release gates add appropriate discipline for an industrial monitoring interface while preserving short feedback cycles.

### Lifecycle and project gates

1. **Requirements understanding and baseline** — turn the supplied overview into functional and non-functional requirements; distinguish present demo behavior from future live-gateway work. Resolve ambiguities explicitly rather than implying unsupported behavior.
2. **Requirements output and architecture** — define the dashboard information model, typed telemetry/sample-data boundary, gateway adapter seam, navigation/view structure, responsive behavior, and static hosting approach. Record the architecture and the requirements-to-verification mapping here and in project documentation.
3. **Design** — settle the visual system, card hierarchy, touch targets, information density, and desktop/tablet/mobile behavior before implementation.
4. **Implementation/coding in increments** — deliver the application shell/navigation and overview telemetry cards first, then faults/events, trends, cells, and settings. Keep sample data and live transport behind a clear adapter boundary; no production gateway protocol is assumed.
5. **Testing and verification** — use static/type diagnostics and production builds; verify component/data-format behavior and responsive rendering. Map verification back to the requirement groups. Any live-gateway, hardware, safety, security, and production acceptance testing remains out of scope until a real interface and system owner are specified.
6. **Exit review, commit, and pull request/merge** — review the final scope, source changes, checks, and documentation. Use the GitHub repository workflow to make the source available. Where the repository workflow supports it, review a pull request before merge; the managed GitHub repository/checkpoint workflow may require commits on `main`, so do not promise a separate PR gate unless that workflow is available.
7. **Release/deployment** — connect the authorized GitHub repository to Vercel and deploy the prototype after build and environment configuration are confirmed. Do not represent a Preview or successful build as a production deployment. Public production release is reported only after Vercel confirms success.
8. **Documentation and maintenance** — document setup, scripts, demo-data limitations, the future gateway integration contract, and deployment steps. Treat feedback, telemetry schema changes, and production-hardening as follow-on increments.

## Implementation approach

- **Frontend:** Flutter + Dart, targeting Flutter Web; compile the static web application for Vercel. No server or database is needed for the demo-only prototype.
- **State:** Flutter `provider`/`ChangeNotifier` for selected view, sample telemetry, and demo refresh state. Keep UI state separate from transport.
- **Telemetry boundary:** typed BMS readings and sample data, with an opt-in browser WebSocket client and JSON parsing. Operating mode follows payloads, cell-balancing status derives from cell telemetry, explicit gateway fault counts are preserved alongside alert details, and events are ordered newest-first. MQTT is deferred until gateway/broker details are known. Do not simulate a successful physical connection.
- **Visualization:** Flutter `CustomPainter` and reusable card/chart widgets for the segmented SOC indicator, temperature range bars, and compact trend charts; standardize V, A, kW, kWh, °C, timestamps, and percentages.
- **Trend interaction:** the 1H/6H/24H controls change distinct, visibly labeled illustrative sample histories; the current snapshot follows Provider telemetry. No historical gateway stream/schema is assumed.
- **Navigation:** Overview, Faults, Trends, Cells, and Settings views behind persistent bottom navigation; responsive card layout from three landscape columns to a single mobile column.
- **Source/release:** pin Flutter SDK **3.47.0 stable**; `scripts/bootstrap_flutter.sh` downloads the official Linux archive and verifies SHA-256 `26cd99d3d94b1367e6b50535a18aeef0282c10a535bbe3ec493534dcdab75296`. The archive is `https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.0-stable.tar.xz`; official release metadata is at `https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json`. Local Preview uses Flutter's web-server target on port 3000. Run `flutter analyze`, Flutter tests, and a release web build; serve generated `build/web` on Vercel. GitHub is the requested source host; Vercel is the requested deployment target, subject to authorized account access.

## Project structure

- `pubspec.yaml` — pinned Flutter constraints plus `provider`, `web_socket_channel`, `cupertino_icons`, and Flutter test dependencies.
- `app.config.ts` — platform project-logo URL metadata required before checkpointing.
- `lib/main.dart` — Flutter entry point and Provider lifecycle; `lib/theme/` owns the visual theme.
- `lib/app.dart` — dashboard shell, selected view, and responsive layout composition.
- `lib/models/` — typed telemetry, alert, event, cell, and gateway status contracts.
- `lib/data/` — visibly labeled sample telemetry and demo events.
- `lib/services/` — Provider state store, demo source, and documented WebSocket/MQTT integration seam.
- `lib/widgets/` — app header, status chips, bottom navigation, measurement/SOC/SOH cards, fault summaries, charts, and event list.
- `lib/views/` — Overview, Faults, Trends, Cells, and Settings content.
- `lib/theme/` — color tokens, type scale, layout breakpoints, and card treatments. View/navigation transitions honor the platform reduced-motion preference.
- `web/` — Flutter Web document shell and static application icons.
- `web/manus-routes.json` — the single-page route manifest (`/`) copied into Preview and Flutter Web output.
- `scripts/` — pinned Flutter bootstrap/build helper used by Vercel.
- `vercel.json` — static Flutter Web build/output configuration for `build/web`.
- `README.md` — local setup, commands, sample-data notice, gateway integration boundary, and deployment notes.

Flutter Web's documented release command is `flutter build web`; it places deployable static assets in `build/web`. Vercel supports a project build command and an explicit static output directory, so the project will use a SHA-verified SDK bootstrap and those build settings rather than relying on automatic framework detection. See [Flutter Web deployment](https://docs.flutter.dev/deployment/web) and [Vercel build configuration](https://vercel.com/docs/builds/configure-a-build).

## Design system

### Design Movement

**Industrial telemetry console / restrained SCADA instrumentation**: a calm, high-contrast control-room reading surface with compact instrument panels, inspired by (but not copied from) the user's reference screenshot.

### Core Principles

1. Read critical battery state at a glance, with clear hierarchy and units.
2. Treat status color as information: green means healthy, orange warns, red marks critical states.
3. Make demo-versus-live data unmistakable; never overstate gateway connectivity.
4. Preserve touch-friendly controls and legibility from wide tablet to narrow mobile.

### Color Philosophy

Use charcoal backgrounds (#1A1A1A, with the deeper #121212 reserved for the outer shell) to reduce glare in industrial settings. Use #222222 for cards, cool light text for primary readings, and muted slate for secondary labels. Preserve the specified #00C853 connected/healthy green, #FF9100 warning/discharge orange, and #D50000 critical red. Use a restrained teal for the SOC segment and chart-series distinction, not as a replacement for semantic status colors.

### Layout Paradigm

A monitor-console composition: narrow instrument header, dense but separated telemetry panels, and an always-available bottom view switcher. On wide landscape displays, the overview uses asymmetric columns that prioritize charge and pack readings; at narrower widths, cards reflow into one readable column and the bottom navigation remains reachable.

### Signature Elements

- A bespoke battery-and-lightning mark paired with a segmented SOC meter.
- Fine instrument-like dividers and small telemetry labels with tabular numerals.
- Small status lights and restrained traces/bars for health, trend, and temperature.

### Interaction Philosophy

Navigation is direct and touch-first; cards expose a single clear primary reading and supporting values. Controls use visible active/focus states. Demo refresh and time-range or filter controls communicate what they change. No control will imply the ability to operate contactors, charge/discharge hardware, or alter safety-critical limits.

### Animation

Use only brief opacity/color transitions for view changes and gentle entry of chart bars. If the demo status uses a pulse, keep it subtle and limited to the simulation indicator. Respect `prefers-reduced-motion`; do not animate numerical readings in a way that obscures accuracy.

### Typography System

Use an Inter/system sans-serif stack, with tabular numerals for measurements and timestamps. Set values large enough for a glance, labels compact but readable, and secondary metadata in muted gray without dropping below accessible contrast targets.

### Brand Essence

**Positioning:** A clear battery telemetry surface for operators who need pack health and operating state at a glance. **Personality:** precise, calm, dependable.

### Brand Voice

Headlines and labels are direct, technical, and concise; microcopy distinguishes measured, simulated, and unavailable data. Examples: “Pack status at a glance.” “Demo stream — gateway not connected.”

### Wordmark & Logo

Use a custom inline battery-outline mark with a lightning cutout and the wordmark “BMS MONITOR”; avoid a generic default-font-only logo. Site favicon/app icon should be derived from that mark.

### Signature Brand Color

A restrained instrument teal (`#27C7BC`) for SOC segmentation and non-semantic chart emphasis. Status colors retain their specified green/orange/red meanings.

## Delivery constraints and open dependencies

- No gateway URL, WebSocket/MQTT message schema, authentication method, or real device credentials were provided; therefore this release uses clearly labeled demo data only.
- The initial sandbox lacked Flutter; the pinned 3.47.0 stable SDK is now installed through the checksum-verified bootstrap. Flutter's official Web release build writes deployable static assets to `build/web`; Vercel serves the configured output directory. See [Flutter Web deployment](https://docs.flutter.dev/deployment/web) and [Vercel build configuration](https://vercel.com/docs/builds/configure-a-build).
- GitHub and Vercel are the requested external destinations. Their current integrations are not enabled for this task; establish the authorized connection through the supported workflow before transfer/deployment. Do not ask the user to paste credentials into chat.
- The available GitHub transfer path may create and connect a new private repository after the owner's confirmation. Repository naming and any Vercel project/domain choices should use values confirmed by the platform or the user, never invented credentials.
- A Vercel deployment will be considered complete only when the deployment result and URL are returned successfully.


### Flutter-specific implementation decision

The user requested Flutter after approving the Agile-first plan. The site will therefore be implemented in **Flutter Web/Dart** (not React). The exact stable SDK is pinned at 3.47.0 and its official archive SHA-256 is verified by `scripts/bootstrap_flutter.sh`. State management is Flutter Provider. A real browser WebSocket client is provided as an opt-in transport adapter; sample telemetry remains the default, and an MQTT adapter is deferred until the gateway/broker details are available. The Flutter web document serves `web/manus-routes.json` as the single `/` route; Vercel builds and serves `build/web`.

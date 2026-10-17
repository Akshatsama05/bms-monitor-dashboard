# BMS Monitor Dashboard — Agile Delivery TODO

> Status legend: `Not started` → `In progress` → `Complete`. Keep acceptance clauses explicit as the work is delivered; do not mark an item complete without evidence.

## 1. Responsive BMS console shell and navigation — Complete

- Target Platform: Cross-platform (optimized primarily for tablet/industrial touch displays in landscape mode, but responsive to mobile viewports).
- Base Layout: Dark mode industrial UI theme utilizing a scaffold with a custom dark background (e.g., Deep Charcoal / Dark Slate #121212).
- Navigation Structure:
  - Top App Bar: Gateway connection status, title, and live timestamp.
  - Main Content Area: Scrollable or grid-based layout housing dashboard cards (GridView or Wrap with Card widgets).
  - Bottom Navigation Bar: Persistent tab bar with icons and labels for Overview, Faults, Trends, Cells, and Settings.
- App Bar / Header elements:
  - Application Title: “BMS MONITOR” with battery icon.
  - Gateway Info: “BATTERY GATEWAY 01”.
  - Connection Status Indicator: Green pulsing or solid dot with label “Connected” and last sync/update timestamp (14:32:08).
  - Date/Time display on the top-right corner.
- Typography: Clean sans-serif font (e.g., Roboto or Inter) with high contrast white/light-grey text for readability in industrial settings.
- The supplied dashboard screenshot is a visual reference only; do not copy it as an image or reproduce it pixel-for-pixel. The handwritten SDLC page informs the process, not product UI content.

## 2. Dashboard energy, pack, and health measurements — Complete

- State of Charge (SOC) Card:
  - Large numerical display: 78%.
  - Segmented progress bar spanning from 0% to 100%.
- Pack Measurements Card:
  - Pack Voltage: 742.6 V.
  - Pack Current: 18.5 A (or +18.4 A).
  - Power: 13.7 kW.
  - Operating Mode / Status: DISCHARGING (styled with distinct badge color).
  - Additional energy stats (Energy Today, Remaining Capacity).
- State of Health (SOH) Card:
  - Percentage display: 96% with a “Healthy” status tag.
  - Secondary metrics: Nominal Capacity (50.0 kWh), Cycle Count (115), and Last Balanced timestamp.

## 3. Temperature, system status, faults, and event history — Complete

- Temperature Ranges Card:
  - Visual bar indicators tracking Minimum (24°C), Average (29°C), and Maximum (34°C) values across zones.
- System Status:
  - Online indicator, current operating mode, cell balancing status.
- Active Faults/Alerts:
  - Conditional styling.
  - Displays “NO ACTIVE FAULTS OR ALERTS” with a success checkmark icon, or detailed counts for warnings and critical faults.
- Recent Events Log:
  - Chronological log items with timestamps and descriptive event messages (e.g., 14:31:55 - Discharge Started, 14:28:10 - HV Contactors Closed).

## 4. Interactive views, responsive telemetry state, and data boundaries — In progress

- Implement the prototype UI in Flutter/Dart as a Flutter Web application suitable for tablet and mobile browsers.
- Persistent navigation provides working views for Overview, Faults, Trends, Cells, and Settings.
- Responsiveness: Use LayoutBuilder and MediaQuery to gracefully adapt card grids from a 3-column landscape view down to a single-column vertical stack for smaller screens.
- State Management: Use Flutter Provider to handle real-time data streaming from the battery gateway (WebSocket / MQTT integration for live voltage, current, and fault updates).
- Localization & Formatting: Standardized number formatting for electrical units (V, A, kW, kWh, °C).
- Until a gateway URL, protocol, message schema, and authentication details are supplied, prototype readings must be clearly labeled as simulated/demo data; do not claim that a physical gateway is connected. Keep the gateway transport extensible for later WebSocket/MQTT integration.

## 5. Agile SDLC, documentation, and delivery outputs — In progress

- Use Agile as the primary delivery lifecycle with small reviewable increments. Keep requirements and architecture understood/documented before implementation, and map requirement groups to appropriate checks.
- Follow the lifecycle from the user's handwritten notes: requirements understanding/output, architecture understanding, design, implementation/coding, testing, exit/commit creation, pull-request creation and merge where supported by the authorized repository workflow, and documentation.
- Theme & Styling palette: Dark background (#1A1A1A), Card backgrounds (#222222), Accent Green (#00C853 for healthy/connected states), Accent Orange/Red (#FF9100 / #D50000 for warnings/discharging/faults).
- Provide a usable prototype website built from the supplied requirements document and visual reference.
- Prepare Flutter Web static output (`build/web`) and the source for the requested Vercel deployment and GitHub repository workflow; use a pinned Flutter SDK build path; report deployment only after the corresponding platform confirms success.
- Provide a ZIP archive of the finished website source as requested; exclude dependencies, secrets, local credentials, and generated build artifacts unless needed for the deployable bundle.
- Document setup, build commands, demo-data limitations, the future gateway integration boundary, and deployment workflow.

### Current status note

- The responsive dashboard, measurements, event/fault views, simulated warning interaction, strict gateway-payload validation, bounded WebSocket reconnect behavior, stale-live-data warning state, dynamic gateway identity, and local safety alerts are implemented and covered by widget/unit tests.
- Current verification evidence: `flutter analyze` clean; all nine Flutter tests pass; the final Flutter Web release build succeeds. The build output includes the declared `/manus-routes.json` route manifest.
- Keep this outcome open until a real gateway endpoint, protocol/message schema, and authentication policy are supplied; the current app explicitly labels simulated telemetry.
- The requested source-plus-build ZIP has been created and passes archive integrity checks. Keep repository transfer and Vercel authorization/deployment open until their respective results are confirmed.

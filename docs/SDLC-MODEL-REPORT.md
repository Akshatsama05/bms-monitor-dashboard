# SDLC Model Report

## 1. Selected model

The project uses **Agile incremental delivery** as its primary software-development lifecycle. It is supported by **V-model-inspired verification** for requirement traceability and **DevOps release practices** for repeatable builds, source review, checkpointing, and deployment.

This is a deliberate hybrid for a read-only industrial monitoring prototype. Agile provides short feedback cycles for responsive UI and operator workflows; verification discipline prevents the prototype from implying unsupported live-gateway or battery-control behavior; DevOps makes the build and release path repeatable.

## 2. Why this model fits

A pure Waterfall process would delay visual and device feedback until late in the project. A pure ad-hoc prototype process would make safety boundaries, telemetry assumptions, and release evidence difficult to review. The selected model preserves iteration while requiring a documented baseline, architecture, acceptance evidence, and release gate.

The project is not a certified safety system. The lifecycle provides proportionate engineering evidence for a prototype and does not replace battery, security, compliance, or operational acceptance reviews.

## 3. Lifecycle stages

### Stage 1 — Requirements baseline

Capture the dashboard goals, operator actors, responsive targets, authentication requirement, telemetry boundary, safety constraints, and deployment expectations. Record them in `docs/SRS.md` and preserve explicit out-of-scope items.

### Stage 2 — Architecture and design

Define the Flutter presentation layer, provider state, typed telemetry boundary, OAuth/session server, container runtime, route manifest, and future gateway boundary. Record system responsibilities and trust boundaries in `docs/ARCHITECTURE.md`.

### Stage 3 — Incremental implementation

Implement in coherent increments: dashboard shell and theme; telemetry models and sample data; overview and secondary views; authentication gate and server session; defensive validation; tests and deployment files. Each increment keeps simulated data visibly separate from future live integration.

### Stage 4 — Verification

Use static analysis, unit tests, widget tests, release builds, route-manifest checks, server health checks, and responsive visual review. Map evidence back to the SRS rather than treating a successful compilation as complete acceptance.

### Stage 5 — Review and checkpoint

Review the diff, documentation, safety wording, dependency changes, and commit message. Use a focused commit subject of 50 characters or fewer where practical, wrap body lines at 72 characters, keep the body meaningful, and never include secrets. Save the accepted source as a canonical checkpoint.

### Stage 6 — Publish and observe

Publish the accepted static build to Vercel after Firebase Authorized domains and provider settings are configured. Confirm the deployment result, then verify sign-in, email verification, Google Sign-In, password reset, logout, and protected dashboard routing on the deployed hostname.

### Stage 7 — Maintenance

Treat gateway schema changes, auth policy changes, alarm thresholds, security findings, and operator feedback as new increments. Update the SRS, architecture, tests, release checklist, and changelog when behavior changes.

## 4. Requirement-to-verification traceability

| Requirement group | Primary verification |
|---|---|
| Authentication and protected routing | Firebase provider configuration, auth controller tests, deployed sign-in and protected-routing review |
| Responsive UI | Widget tests plus desktop/tablet/mobile review |
| Telemetry model and validation | Unit tests for parsing, bounds, ordering, and derived alerts |
| Dashboard navigation | Widget tests for Overview, Faults, Trends, Cells, and Settings |
| Read-only safety boundary | Source review; absence of control actions; SRS non-goals |
| Build reproducibility | Pinned Flutter bootstrap, `flutter analyze`, `flutter test`, release build |
| Static deployment readiness | Vercel build output, security headers, Firebase Authorized domains, static route response |
| Documentation and handoff | SRS, architecture, README, deployment notes, and commit review |

## 5. Definition of done

An increment is complete only when its behavior is implemented, documented, tested at the appropriate level, and consistent with the safety boundary. A production deployment is additionally complete only when the platform reports a successful published version and the required runtime environment is configured securely.

## 6. Remaining acceptance work

Live gateway integration, battery-specific alarm thresholds, security testing, identity/role policy, data retention, alert escalation, monitoring, disaster recovery, and operational sign-off remain separate production work items. They must not be inferred from this prototype's UI or simulated telemetry.

# Security and Safety Boundary

## Current protections

- HTTPS deployments require `wss://` gateway URLs.
- Live JSON is validated before it reaches dashboard state.
- Message and collection sizes are bounded.
- Invalid endpoints do not trigger repeated connection attempts.
- Disconnects preserve the last reading and mark it stale.
- Vercel response headers include MIME sniffing protection, referrer policy, permissions policy, and HSTS.
- No credentials are included in the repository.

## Important limitation

A Flutter Web build is public client code. Any value passed through `--dart-define` or compiled into the JavaScript bundle can be inspected by users. Do not use frontend variables for private API keys, gateway passwords, client secrets, or certificates.

## Required production controls

A production system needs an authenticated backend/proxy between the browser and the private gateway, short-lived user sessions, role-based access, device identity, server-side schema validation, rate limiting, audit logs, secret storage, alert escalation, backup/recovery, vulnerability review, and monitoring.

## Safety statement

The dashboard is informational and read-only. It is not a protection relay, BMS controller, or safety instrument. Local alert thresholds are prototype defaults and must not be treated as certified limits. Battery-control functionality is intentionally absent.

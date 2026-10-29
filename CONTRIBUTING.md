# Contributing

## Development workflow

1. Create a focused branch from `main`.
2. Read the relevant design and security notes in `docs/`.
3. Keep live gateway changes behind `BmsGatewayClient` and `BmsTelemetry` validation.
4. Do not add battery-control commands to this repository without a separate approved architecture and safety review.
5. Add or update tests for every behavior change.
6. Run `bash scripts/vercel_build.sh` before opening a review.
7. Review the generated diff for credentials, private endpoints, build output, and accidental generated files.

## Coding conventions

- Keep models, services, views, and reusable widgets in their documented directories.
- Prefer explicit names and typed values over dynamic maps outside the parser boundary.
- Keep simulated/demo behavior visibly separate from live behavior.
- Treat missing or invalid telemetry as unavailable, never as a healthy zero.
- Preserve responsive behavior and reduced-motion considerations.

## Pull-request checklist

- [ ] Scope is small and described clearly.
- [ ] Tests cover the changed behavior.
- [ ] `flutter analyze` is clean.
- [ ] `bash scripts/vercel_build.sh` succeeds.
- [ ] Documentation and known limitations are updated.
- [ ] No secrets or private gateway information are included.

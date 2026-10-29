# Review and Release Checklist

## Source review

- [ ] Confirm repository owner, branch, and commit are correct.
- [ ] Confirm no credentials, tokens, certificates, `.env` files, `.dart_tool/`, `build/`, or logs are committed.
- [ ] Review `README.md`, architecture, security, gateway contract, and limitations.
- [ ] Confirm the application is described as a read-only prototype.

## Automated checks

```bash
bash scripts/vercel_build.sh
```

Expected results:

- [ ] `flutter analyze` reports no issues.
- [ ] All tests pass.
- [ ] `build/web/index.html` exists.
- [ ] `build/web/manus-routes.json` exists and returns HTTP 200 when served.

## Manual UI review

- [ ] Overview, Faults, Trends, Cells, and Settings navigation works.
- [ ] Demo data is visibly labeled simulated.
- [ ] Low SOH, fault/emergency mode, and stale-data states are not shown as healthy.
- [ ] Layout works at tablet landscape and narrow mobile widths.
- [ ] No control command or hardware action is exposed.

## Deployment review

- [ ] Vercel imports the repository with no unsupported framework setting.
- [ ] Build command is `bash scripts/vercel_build.sh`.
- [ ] Output directory is `build/web`.
- [ ] No private gateway secret is added to frontend environment variables.
- [ ] Production URL, domain, logs, rollback, and ownership are recorded.

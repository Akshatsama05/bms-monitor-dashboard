# Known Limitations

| Area | Current state | Needed for production |
|---|---|---|
| Telemetry source | Demo by default; browser WebSocket adapter available | Real gateway contract and staging endpoint |
| Authentication | Not implemented in the frontend adapter | Authenticated backend/proxy and user identity provider |
| Historical data | Fixed illustrative trend series | Time-series database and backend queries |
| Alerts | Local prototype alerts and simulated warning | Approved thresholds, notification service, acknowledgement/escalation |
| User access | No accounts or roles | Viewer/operator/admin model and identity provider |
| Hardware control | Not implemented | Separate safety-reviewed control system; not part of this project |
| Compliance | No certification or penetration testing | Qualified engineering, security, and compliance review |
| Deployment | Vercel-ready static build; account deployment is external | Authorized GitHub/Vercel project, domain, monitoring, and rollback process |
| Alarm thresholds | Defensive prototype thresholds | Battery-specific manufacturer and engineering approval |
| Device identity | Payload-provided display name | Trusted registration and server-side identity verification |

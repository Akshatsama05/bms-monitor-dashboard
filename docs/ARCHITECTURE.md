# Architecture

## Current prototype flow

```text
Demo telemetry or browser WebSocket
              |
              v
BmsGatewayClient / demo source
              |
              v
BmsDashboardProvider
              |
              v
Flutter views and reusable widgets
              |
              v
Static Flutter Web build
```

### Current responsibilities

- `BmsTelemetry` is the typed boundary for measurements, cells, events, and alerts.
- `BmsTelemetry.tryFromJson` rejects incomplete, implausible, or oversized live packets.
- `WebSocketBmsGatewayClient` validates the URL scheme, limits message size, parses JSON, and emits validated readings.
- `BmsDashboardProvider` owns connection lifecycle, bounded reconnects, stale state, last-live-reading preservation, and demo/live labeling.
- Views and widgets render state; they do not send battery commands.

## Recommended production flow

```text
Battery/BMS
    |
    v
Private protocol adapter (MQTT/CAN/Modbus/REST/WebSocket)
    |
    v
Authenticated backend gateway
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

The browser should not hold private gateway credentials or connect directly to a private battery network. A backend should own gateway authentication, device identity, schema versioning, rate limits, audit logs, threshold configuration, and historical storage.

## Deliberate non-goals

This repository does not implement charging, discharging, contactor, reset, configuration, or other battery-control commands. It is read-only by design until a separate safety and authorization architecture is approved.

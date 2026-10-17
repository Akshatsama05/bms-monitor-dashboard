# Gateway Integration

## Current adapter

The current browser adapter expects a JSON object per telemetry message. It is intended for a browser-safe, read-only staging gateway. The transport must be `ws://` for local HTTP development or `wss://` for deployed HTTPS.

## Required fields

The validated live path requires:

- `soc`
- `packVoltageV`
- `packCurrentA`
- `powerKw`
- `energyTodayKwh`
- `remainingCapacityKwh`
- `sohPercent`
- `nominalCapacityKwh`
- `cycleCount`
- `operatingMode`
- `minTempC`, `avgTempC`, `maxTempC`
- `lastBalanced`

Optional fields include `gatewayName` or `gatewayId`, `temperatureZones`, `cells`, `events`, `alerts`, `warnings`, and `criticalFaults`.

## Example

```json
{
  "gatewayName": "BATTERY GATEWAY 01",
  "timestamp": "2026-10-17T13:32:08Z",
  "lastBalanced": "2026-10-17T12:32:08Z",
  "soc": 78,
  "packVoltageV": 742.6,
  "packCurrentA": 18.5,
  "powerKw": 13.7,
  "energyTodayKwh": 124.8,
  "remainingCapacityKwh": 46.8,
  "sohPercent": 96,
  "nominalCapacityKwh": 50,
  "cycleCount": 115,
  "operatingMode": "Discharging",
  "minTempC": 24,
  "avgTempC": 29,
  "maxTempC": 34,
  "temperatureZones": [],
  "cells": [],
  "events": [],
  "alerts": [],
  "warnings": 0,
  "criticalFaults": 0
}
```

## Defensive limits

The client rejects messages larger than 256 KB, more than 500 cells, more than 200 events, more than 100 alerts, or more than 100 temperature zones. It rejects missing required fields, invalid SOC/SOH ranges, impossible temperature ordering, implausible electrical values, invalid cycle counts, and unknown operating modes.

These are defensive software limits, not approved battery operating limits. Thresholds must be supplied and approved for the actual battery chemistry and manufacturer.

## Required information before real integration

Provide through an approved secure process: manufacturer/model, gateway model, protocol documentation, schema/version, authentication method, device identity, allowed origins, TLS requirements, test endpoint, sample payload, battery chemistry, and approved alarm thresholds. Never commit secrets or private certificates.

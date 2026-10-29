import 'package:flutter_test/flutter_test.dart';

import '../lib/models/bms_telemetry.dart';

void main() {
  test('parses standard battery measurement units and fault counts', () {
    final telemetry = BmsTelemetry.fromJson({
      'timestamp': '2026-10-17T14:32:08Z',
      'soc': 78,
      'packVoltageV': 742.6,
      'packCurrentA': 18.5,
      'powerKw': 13.7,
      'energyTodayKwh': 124.8,
      'remainingCapacityKwh': 46.8,
      'sohPercent': 96,
      'nominalCapacityKwh': 50,
      'cycleCount': 115,
      'lastBalanced': '2026-10-17T13:32:08Z',
      'operatingMode': 'Discharging',
      'minTempC': 24,
      'avgTempC': 29,
      'maxTempC': 34,
      'warnings': 0,
      'criticalFaults': 0,
      'alerts': [],
    });

    expect(telemetry.soc, 78);
    expect(telemetry.packVoltageV, 742.6);
    expect(telemetry.packCurrentA, 18.5);
    expect(telemetry.powerKw, 13.7);
    expect(telemetry.energyTodayKwh, 124.8);
    expect(telemetry.remainingCapacityKwh, 46.8);
    expect(telemetry.sohPercent, 96);
    expect(telemetry.cycleCount, 115);
    expect(telemetry.operatingMode, 'Discharging');
    expect(telemetry.minTempC, 24);
    expect(telemetry.avgTempC, 29);
    expect(telemetry.maxTempC, 34);
    expect(telemetry.alerts, isEmpty);
  });

  test('preserves alert details and supplements them to match gateway aggregate counts', () {
    final telemetry = BmsTelemetry.fromJson({
      'alerts': [
        {
          'title': 'Low temperature delta',
          'severity': 'warning',
          'detail': 'Review the zone.',
          'time': '14:30:00',
        },
      ],
      'warnings': 2,
      'criticalFaults': 1,
    });

    expect(
      telemetry.alerts.where(
        (alert) => alert.severity == AlertSeverity.warning,
      ),
      hasLength(2),
    );
    expect(
      telemetry.alerts.where(
        (alert) => alert.severity == AlertSeverity.critical,
      ),
      hasLength(1),
    );
    expect(telemetry.alerts.first.title, 'Low temperature delta');
  });

  test('sorts recent gateway events in reverse chronological order', () {
    final telemetry = BmsTelemetry.fromJson({
      'events': [
        {'time': '14:02:40', 'message': 'System Wake'},
        {'time': '14:31:55', 'message': 'Discharge Started'},
        {'time': '14:28:10', 'message': 'HV Contactors Closed'},
      ],
    });

    expect(telemetry.events.map((event) => event.time).toList(), [
      '14:31:55',
      '14:28:10',
      '14:02:40',
    ]);
  });

  test('accepts string-formatted numeric and boolean gateway values', () {
    final telemetry = BmsTelemetry.fromJson({
      'soc': '78',
      'packVoltageV': '742.6',
      'warnings': '1',
      'cells': [
        {
          'name': 'C01',
          'voltageV': '3.420',
          'temperatureC': '24',
          'balancing': 'true',
        },
      ],
      'alerts': [
        {
          'title': 'Review',
          'severity': 'WARNING',
          'detail': 'Check pack.',
          'time': '14:00:00',
        },
      ],
    });

    expect(telemetry.soc, 78);
    expect(telemetry.packVoltageV, 742.6);
    expect(telemetry.cells.single.balancing, isTrue);
    expect(telemetry.alerts.single.severity, AlertSeverity.warning);
  });

  test('rejects incomplete or out-of-range live telemetry', () {
    expect(BmsTelemetry.tryFromJson({'soc': 78}), isNull);
    expect(
      BmsTelemetry.tryFromJson({
        'soc': 120,
        'packVoltageV': 742.6,
        'packCurrentA': 18.5,
        'powerKw': 13.7,
        'energyTodayKwh': 124.8,
        'remainingCapacityKwh': 46.8,
        'sohPercent': 96,
        'nominalCapacityKwh': 50,
        'cycleCount': 115,
        'operatingMode': 'Discharging',
        'minTempC': 24,
        'avgTempC': 29,
        'maxTempC': 34,
        'lastBalanced': '2026-10-17T13:32:08Z',
      }),
      isNull,
    );
  });

  test('derives local safety alerts from low health and temperature', () {
    final telemetry = BmsTelemetry.fromJson({
      'soc': 5,
      'sohPercent': 55,
      'minTempC': 24,
      'avgTempC': 50,
      'maxTempC': 65,
    });

    expect(
      telemetry.safetyAlerts.map((alert) => alert.title),
      containsAll([
        'Low state of health',
        'Low state of charge',
        'High pack temperature',
      ]),
    );
  });
}

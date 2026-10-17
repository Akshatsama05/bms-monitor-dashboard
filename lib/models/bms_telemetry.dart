class TemperatureZone {
  const TemperatureZone({required this.label, required this.temperatureC});

  final String label;
  final double temperatureC;
}

class CellReading {
  const CellReading({
    required this.name,
    required this.voltageV,
    required this.temperatureC,
    required this.balancing,
  });

  final String name;
  final double voltageV;
  final double temperatureC;
  final bool balancing;
}

class BmsEvent {
  const BmsEvent({
    required this.time,
    required this.message,
    required this.kind,
  });

  final String time;
  final String message;
  final String kind;
}

enum AlertSeverity { warning, critical }

class TelemetryValidationException implements Exception {
  const TelemetryValidationException(this.message);
  final String message;

  @override
  String toString() => 'TelemetryValidationException: $message';
}

class BmsAlert {
  const BmsAlert({
    required this.title,
    required this.detail,
    required this.severity,
    required this.time,
  });

  final String title;
  final String detail;
  final AlertSeverity severity;
  final String time;

  factory BmsAlert.fromJson(Map<String, dynamic> json) {
    final severityName =
        json['severity']?.toString().toLowerCase() ?? 'warning';
    return BmsAlert(
      title: json['title']?.toString() ?? 'Battery alert',
      detail: json['detail']?.toString() ?? 'Review gateway telemetry.',
      severity: severityName == 'critical'
          ? AlertSeverity.critical
          : AlertSeverity.warning,
      time: json['time']?.toString() ?? '--:--:--',
    );
  }
}

class BmsTelemetry {
  const BmsTelemetry({
    required this.gatewayName,
    required this.timestamp,
    required this.soc,
    required this.packVoltageV,
    required this.packCurrentA,
    required this.powerKw,
    required this.energyTodayKwh,
    required this.remainingCapacityKwh,
    required this.sohPercent,
    required this.nominalCapacityKwh,
    required this.cycleCount,
    required this.lastBalanced,
    required this.operatingMode,
    required this.minTempC,
    required this.avgTempC,
    required this.maxTempC,
    required this.temperatureZones,
    required this.cells,
    required this.events,
    required this.alerts,
  });

  final String gatewayName;
  final DateTime timestamp;
  final double soc;
  final double packVoltageV;
  final double packCurrentA;
  final double powerKw;
  final double energyTodayKwh;
  final double remainingCapacityKwh;
  final double sohPercent;
  final double nominalCapacityKwh;
  final int cycleCount;
  final DateTime lastBalanced;
  final String operatingMode;
  final double minTempC;
  final double avgTempC;
  final double maxTempC;
  final List<TemperatureZone> temperatureZones;
  final List<CellReading> cells;
  final List<BmsEvent> events;
  final List<BmsAlert> alerts;

  List<BmsAlert> get safetyAlerts {
    final now = timestamp.toLocal();
    final alerts = <BmsAlert>[];
    if (sohPercent < 80) {
      alerts.add(
        BmsAlert(
          title: 'Low state of health',
          detail:
              'SOH is ${sohPercent.toStringAsFixed(0)}%, below the 80% review threshold.',
          severity: sohPercent < 60
              ? AlertSeverity.critical
              : AlertSeverity.warning,
          time: _clock(now),
        ),
      );
    }
    if (soc < 10) {
      alerts.add(
        BmsAlert(
          title: 'Low state of charge',
          detail:
              'SOC is ${soc.toStringAsFixed(0)}%, below the 10% warning threshold.',
          severity: AlertSeverity.warning,
          time: _clock(now),
        ),
      );
    }
    if (maxTempC >= 45) {
      alerts.add(
        BmsAlert(
          title: 'High pack temperature',
          detail:
              'Maximum reported temperature is ${maxTempC.toStringAsFixed(0)} °C.',
          severity: maxTempC >= 60
              ? AlertSeverity.critical
              : AlertSeverity.warning,
          time: _clock(now),
        ),
      );
    }
    return alerts;
  }

  static const _requiredLiveFields = [
    'soc',
    'packVoltageV',
    'packCurrentA',
    'powerKw',
    'energyTodayKwh',
    'remainingCapacityKwh',
    'sohPercent',
    'nominalCapacityKwh',
    'cycleCount',
    'operatingMode',
    'minTempC',
    'avgTempC',
    'maxTempC',
    'lastBalanced',
  ];

  static BmsTelemetry? tryFromJson(
    Map<String, dynamic> json, {
    DateTime? receivedAt,
  }) {
    if (_requiredLiveFields.any((key) => !json.containsKey(key))) return null;
    if ((json['cells'] is List && (json['cells'] as List).length > 500) ||
        (json['events'] is List && (json['events'] as List).length > 200) ||
        (json['alerts'] is List && (json['alerts'] as List).length > 100) ||
        (json['temperatureZones'] is List &&
            (json['temperatureZones'] as List).length > 100)) {
      return null;
    }
    final telemetry = BmsTelemetry.fromJson(json, receivedAt: receivedAt);
    if (!telemetry.soc.isFinite ||
        telemetry.soc < 0 ||
        telemetry.soc > 100 ||
        !telemetry.sohPercent.isFinite ||
        telemetry.sohPercent < 0 ||
        telemetry.sohPercent > 100 ||
        !telemetry.packVoltageV.isFinite ||
        telemetry.packVoltageV <= 0 ||
        telemetry.packVoltageV > 2000 ||
        !telemetry.packCurrentA.isFinite ||
        telemetry.packCurrentA.abs() > 100000 ||
        !telemetry.powerKw.isFinite ||
        telemetry.powerKw.abs() > 100000 ||
        !telemetry.energyTodayKwh.isFinite ||
        telemetry.energyTodayKwh < 0 ||
        !telemetry.remainingCapacityKwh.isFinite ||
        telemetry.remainingCapacityKwh < 0 ||
        telemetry.cycleCount < 0 ||
        telemetry.cycleCount > 1000000 ||
        !telemetry.minTempC.isFinite ||
        !telemetry.avgTempC.isFinite ||
        !telemetry.maxTempC.isFinite ||
        telemetry.minTempC < -80 ||
        telemetry.maxTempC > 150 ||
        telemetry.minTempC > telemetry.avgTempC ||
        telemetry.avgTempC > telemetry.maxTempC ||
        telemetry.operatingMode == 'Unknown') {
      return null;
    }
    if (telemetry.cells.length > 500 ||
        telemetry.events.length > 200 ||
        telemetry.alerts.length > 100)
      return null;
    return telemetry;
  }

  factory BmsTelemetry.fromJson(
    Map<String, dynamic> json, {
    DateTime? receivedAt,
  }) {
    double number(String key, [double fallback = 0]) {
      final value = json[key];
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
    }

    int integer(String key, [int fallback = 0]) {
      final value = json[key];
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString().trim() ?? '') ?? fallback;
    }

    DateTime timestampFor(String key, DateTime fallback) {
      final value = json[key];
      final text = value?.toString();
      return text == null ? fallback : DateTime.tryParse(text) ?? fallback;
    }

    List<Map<String, dynamic>> objects(String key) {
      final value = json[key];
      if (value is! List) return const [];
      final limit = switch (key) {
        'cells' => 500,
        'events' => 200,
        'alerts' => 100,
        'temperatureZones' => 100,
        _ => 500,
      };
      if (value.length > limit) return const [];
      return value
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    final now = receivedAt ?? DateTime.now();
    final zones = objects('temperatureZones')
        .map(
          (item) => TemperatureZone(
            label: item['label']?.toString() ?? 'Zone',
            temperatureC: _numberValue(item['temperatureC']),
          ),
        )
        .toList();
    if (zones.isEmpty) {
      zones.addAll([
        TemperatureZone(label: 'MIN', temperatureC: number('minTempC')),
        TemperatureZone(label: 'AVG', temperatureC: number('avgTempC')),
        TemperatureZone(label: 'MAX', temperatureC: number('maxTempC')),
      ]);
    }
    final cells = objects('cells')
        .map(
          (item) => CellReading(
            name: item['name']?.toString() ?? 'Cell',
            voltageV: _numberValue(item['voltageV']),
            temperatureC: _numberValue(item['temperatureC']),
            balancing: _boolValue(item['balancing']),
          ),
        )
        .toList();
    final events =
        objects('events')
            .map(
              (item) => BmsEvent(
                time: item['time']?.toString() ?? '--:--:--',
                message: item['message']?.toString() ?? 'Gateway event',
                kind: item['kind']?.toString() ?? 'event',
              ),
            )
            .toList()
          ..sort((a, b) => _eventTime(b.time).compareTo(_eventTime(a.time)));
    final alerts = objects('alerts').map(BmsAlert.fromJson).toList();
    final existingWarnings = alerts
        .where((alert) => alert.severity == AlertSeverity.warning)
        .length;
    final existingCritical = alerts
        .where((alert) => alert.severity == AlertSeverity.critical)
        .length;
    final reportedWarnings = integer('warnings', existingWarnings);
    final reportedCritical = integer('criticalFaults', existingCritical);
    for (var index = existingWarnings; index < reportedWarnings; index++) {
      alerts.add(
        BmsAlert(
          title: 'Warning ${index + 1}',
          detail: 'The gateway reported a warning condition.',
          severity: AlertSeverity.warning,
          time: '--:--:--',
        ),
      );
    }
    for (var index = existingCritical; index < reportedCritical; index++) {
      alerts.add(
        BmsAlert(
          title: 'Critical fault ${index + 1}',
          detail: 'The gateway reported a critical fault condition.',
          severity: AlertSeverity.critical,
          time: '--:--:--',
        ),
      );
    }

    return BmsTelemetry(
      gatewayName:
          (json['gatewayName'] ?? json['gatewayId'])
                  ?.toString()
                  .trim()
                  .isNotEmpty ==
              true
          ? (json['gatewayName'] ?? json['gatewayId']).toString().trim()
          : 'BATTERY GATEWAY 01',
      timestamp: timestampFor('timestamp', now),
      soc: number('soc'),
      packVoltageV: number('packVoltageV'),
      packCurrentA: number('packCurrentA'),
      powerKw: number('powerKw'),
      energyTodayKwh: number('energyTodayKwh'),
      remainingCapacityKwh: number('remainingCapacityKwh'),
      sohPercent: number('sohPercent'),
      nominalCapacityKwh: number('nominalCapacityKwh'),
      cycleCount: integer('cycleCount'),
      lastBalanced: timestampFor('lastBalanced', now),
      operatingMode:
          json['operatingMode'] is String &&
              (json['operatingMode'] as String).trim().isNotEmpty
          ? (json['operatingMode'] as String).trim()
          : 'Unknown',
      minTempC: number('minTempC'),
      avgTempC: number('avgTempC'),
      maxTempC: number('maxTempC'),
      temperatureZones: zones,
      cells: cells,
      events: events,
      alerts: alerts,
    );
  }

  static bool _boolValue(Object? value) {
    if (value is bool) return value;
    return switch (value?.toString().trim().toLowerCase()) {
      'true' || '1' || 'yes' || 'on' => true,
      _ => false,
    };
  }

  static double _numberValue(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static int _eventTime(String value) {
    final parts = value.split(':').map(int.tryParse).toList();
    if (parts.length < 2 || parts.any((part) => part == null)) return -1;
    return parts[0]! * 3600 +
        parts[1]! * 60 +
        (parts.length > 2 ? parts[2] ?? 0 : 0);
  }

  static String _clock(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
}

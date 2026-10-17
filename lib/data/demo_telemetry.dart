import '../models/bms_telemetry.dart';

BmsTelemetry demoTelemetry(DateTime now) {
  const zoneTemps = <double>[24, 25, 29, 34];
  const zoneNames = <String>['24–26', '25–28', '26–29', '31–34'];
  final cells = List<CellReading>.generate(12, (index) {
    final step = (index % 4) - 1.5;
    return CellReading(
      name: 'C${(index + 1).toString().padLeft(2, '0')}',
      voltageV: 3.43 + (step * 0.006),
      temperatureC: 25 + ((index * 3) % 9).toDouble(),
      balancing: index == 5,
    );
  });

  return BmsTelemetry(
    gatewayName: 'BATTERY GATEWAY 01',
    timestamp: now,
    soc: 78,
    packVoltageV: 742.6,
    packCurrentA: 18.5,
    powerKw: 13.7,
    energyTodayKwh: 124.8,
    remainingCapacityKwh: 46.8,
    sohPercent: 96,
    nominalCapacityKwh: 50,
    cycleCount: 115,
    lastBalanced: now.subtract(const Duration(hours: 1)),
    operatingMode: 'Discharging',
    minTempC: 24,
    avgTempC: 29,
    maxTempC: 34,
    temperatureZones: List<TemperatureZone>.generate(
      zoneTemps.length,
      (index) => TemperatureZone(
        label: zoneNames[index],
        temperatureC: zoneTemps[index],
      ),
    ),
    cells: cells,
    events: const [
      BmsEvent(time: '14:31:55', message: 'Discharge Started', kind: 'power'),
      BmsEvent(
        time: '14:28:10',
        message: 'HV Contactors Closed',
        kind: 'switch',
      ),
      BmsEvent(time: '14:15:01', message: 'System Wake', kind: 'system'),
      BmsEvent(
        time: '14:02:40',
        message: 'Charge Cycle Complete',
        kind: 'cycle',
      ),
    ],
    alerts: const [],
  );
}

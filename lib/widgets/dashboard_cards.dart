import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/bms_telemetry.dart';
import '../services/bms_dashboard_provider.dart';
import '../theme/app_theme.dart';
import 'common.dart';

Color _modeColor(String mode) {
  final value = mode.toLowerCase();
  if (value.contains('fault') || value.contains('emergency'))
    return BmsColors.critical;
  if (value.contains('discharg') ||
      value.contains('warn') ||
      value == 'unknown')
    return BmsColors.warning;
  if (value.contains('charg') ||
      value.contains('idle') ||
      value.contains('standby'))
    return BmsColors.healthy;
  return BmsColors.warning;
}

IconData _modeIcon(String mode) {
  final value = mode.toLowerCase();
  if (value.contains('fault') || value.contains('emergency'))
    return Icons.error_rounded;
  if (value.contains('charg')) return Icons.north_east_rounded;
  if (value.contains('discharg')) return Icons.south_east_rounded;
  return Icons.info_outline_rounded;
}

class SocCard extends StatelessWidget {
  const SocCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<BmsDashboardProvider>().telemetry;
    final filled = (data.soc / 100 * 28).round().clamp(0, 28);
    return BmsPanel(
      title: 'State of charge (SOC)',
      trailing: const BmsStatusPill(label: 'PACK', color: BmsColors.teal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.soc.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 46,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 5),
                child: Text(
                  'STATE OF CHARGE',
                  style: TextStyle(
                    color: BmsColors.muted,
                    fontSize: 9,
                    letterSpacing: .6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: List<Widget>.generate(
              28,
              (index) => Expanded(
                child: Container(
                  height: 21,
                  margin: EdgeInsets.only(right: index == 27 ? 0 : 3),
                  decoration: BoxDecoration(
                    color: index < filled
                        ? (index < 22 ? BmsColors.teal : BmsColors.warning)
                        : BmsColors.shell,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: BmsColors.border.withValues(alpha: .8),
                      width: .5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ScaleLabel('0%'),
              _ScaleLabel('25%'),
              _ScaleLabel('50%'),
              _ScaleLabel('75%'),
              _ScaleLabel('100%'),
            ],
          ),
        ],
      ),
    );
  }
}

class PackMeasurementsCard extends StatelessWidget {
  const PackMeasurementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<BmsDashboardProvider>().telemetry;
    final modeColor = _modeColor(data.operatingMode);
    return BmsPanel(
      title: 'Pack measurements',
      trailing: BmsStatusPill(
        label: data.operatingMode.toUpperCase(),
        color: modeColor,
        icon: _modeIcon(data.operatingMode),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BmsMetric(
                  value: data.packVoltageV.toStringAsFixed(1),
                  unit: 'V',
                  label: 'Pack voltage',
                  valueSize: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BmsMetric(
                  value: data.powerKw.toStringAsFixed(1),
                  unit: 'kW',
                  label: 'Power',
                  valueColor: BmsColors.warning,
                  valueSize: 24,
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(width: 46, height: 40, child: _Sparkline()),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: BmsMetric(
                  value: data.packCurrentA.toStringAsFixed(1),
                  unit: 'A',
                  label: 'Pack current',
                  valueSize: 23,
                ),
              ),
              Expanded(
                child: BmsMetric(
                  value: data.energyTodayKwh.toStringAsFixed(1),
                  unit: 'kWh',
                  label: 'Energy today',
                  valueSize: 16,
                ),
              ),
              Expanded(
                child: BmsMetric(
                  value: data.remainingCapacityKwh.toStringAsFixed(1),
                  unit: 'kWh',
                  label: 'Remaining cap.',
                  valueSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HealthCard extends StatelessWidget {
  const HealthCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<BmsDashboardProvider>().telemetry;
    final sohColor = !data.sohPercent.isFinite
        ? BmsColors.muted
        : data.sohPercent < 60
        ? BmsColors.critical
        : data.sohPercent < 80
        ? BmsColors.warning
        : BmsColors.healthy;
    final sohLabel = !data.sohPercent.isFinite
        ? 'Unavailable'
        : data.sohPercent < 60
        ? 'Critical'
        : data.sohPercent < 80
        ? 'Review'
        : 'Healthy';
    final balancedAt = data.lastBalanced.toLocal();
    final balancedTime =
        '${balancedAt.hour.toString().padLeft(2, '0')}:${balancedAt.minute.toString().padLeft(2, '0')}:${balancedAt.second.toString().padLeft(2, '0')}';
    return BmsPanel(
      title: 'State of health (SOH)',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: (data.sohPercent / 100).clamp(0.0, 1.0),
                        strokeWidth: 6,
                        backgroundColor: BmsColors.border,
                        color: BmsColors.healthy,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${data.sohPercent.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: BmsColors.healthy,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'SOH',
                          style: TextStyle(
                            color: BmsColors.muted,
                            fontSize: 8,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.favorite_rounded, color: sohColor, size: 20),
                  SizedBox(height: 4),
                  Text(
                    sohLabel,
                    style: TextStyle(
                      color: sohColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          BmsInfoRow(
            label: 'Nominal capacity',
            value: '${data.nominalCapacityKwh.toStringAsFixed(1)} kWh',
          ),
          BmsInfoRow(label: 'Cycle count', value: '${data.cycleCount}'),
          BmsInfoRow(label: 'Last balanced', value: balancedTime),
        ],
      ),
    );
  }
}

class TemperatureCard extends StatelessWidget {
  const TemperatureCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<BmsDashboardProvider>().telemetry;
    final zones = data.temperatureZones;
    return BmsPanel(
      title: 'Temperature ranges',
      trailing: const Icon(
        Icons.thermostat_rounded,
        color: BmsColors.muted,
        size: 17,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: zones.map((zone) {
                final ratio = (zone.temperatureC / 40).clamp(.05, 1.0);
                final color = zone.temperatureC >= data.maxTempC
                    ? BmsColors.warning
                    : BmsColors.teal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${zone.temperatureC.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            color: BmsColors.text,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          height: 92.0 * ratio.toDouble(),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [color, color.withValues(alpha: .42)],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          zone.label,
                          style: const TextStyle(
                            color: BmsColors.muted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 18, color: BmsColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TempSummary(
                label: 'MIN',
                value: data.minTempC,
                color: BmsColors.teal,
              ),
              _TempSummary(
                label: 'AVG',
                value: data.avgTempC,
                color: BmsColors.text,
              ),
              _TempSummary(
                label: 'MAX',
                value: data.maxTempC,
                color: BmsColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BmsDashboardProvider>();
    final telemetry = model.telemetry;
    final statusColor = model.isTelemetryStale
        ? BmsColors.warning
        : model.isLive || model.connectionLabel == 'CONNECTED • DEMO'
        ? BmsColors.healthy
        : BmsColors.teal;
    final balancingStatus = telemetry.cells.isEmpty
        ? 'Unknown'
        : telemetry.cells.any((cell) => cell.balancing)
        ? 'Active'
        : 'Idle';
    final modeColor = _modeColor(telemetry.operatingMode);
    return BmsPanel(
      title: 'System status',
      child: Column(
        children: [
          Row(
            children: [
              BmsStatusDot(color: statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  model.isTelemetryStale
                      ? 'Live data stale • reconnecting'
                      : model.isLive
                      ? 'Online & monitoring'
                      : model.connectionLabel == 'CONNECTED • DEMO'
                      ? 'Demo stream active'
                      : 'Gateway unavailable • demo fallback',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              BmsStatusPill(label: model.sourceLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 9),
          BmsInfoRow(
            label: 'Current mode',
            value: telemetry.operatingMode,
            valueColor: modeColor,
          ),
          BmsInfoRow(
            label: 'Cell balancing',
            value: balancingStatus,
            valueColor: balancingStatus == 'Active'
                ? BmsColors.teal
                : BmsColors.muted,
          ),
        ],
      ),
    );
  }
}

class FaultsCard extends StatelessWidget {
  const FaultsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BmsDashboardProvider>();
    final alerts = model.activeAlerts;
    if (alerts.isEmpty) {
      return BmsPanel(
        title: 'Active faults',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                Text(
                  'NO ACTIVE FAULTS OR ALERTS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: BmsColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .4,
                  ),
                ),
                SizedBox(height: 12),
                Icon(
                  Icons.check_circle_rounded,
                  color: BmsColors.healthy,
                  size: 42,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final critical = model.criticalCount;
    final warnings = model.warningCount;
    return BmsPanel(
      title: 'Active faults',
      trailing: BmsStatusPill(
        label: '${alerts.length} ACTIVE',
        color: critical > 0 ? BmsColors.critical : BmsColors.warning,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _FaultCount(
                label: 'WARNINGS',
                count: warnings,
                color: BmsColors.warning,
              ),
              const SizedBox(width: 14),
              _FaultCount(
                label: 'CRITICAL',
                count: critical,
                color: BmsColors.critical,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final alert in alerts.take(2))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    alert.severity == AlertSeverity.critical
                        ? Icons.error_rounded
                        : Icons.warning_amber_rounded,
                    color: alert.severity == AlertSeverity.critical
                        ? BmsColors.critical
                        : BmsColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          alert.detail,
                          style: const TextStyle(
                            color: BmsColors.muted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class RecentEventsCard extends StatelessWidget {
  const RecentEventsCard({super.key});

  IconData _iconFor(String kind) => switch (kind) {
    'power' => Icons.schedule_rounded,
    'switch' => Icons.electric_bolt_rounded,
    'system' => Icons.power_settings_new_rounded,
    'cycle' => Icons.sync_rounded,
    _ => Icons.circle_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final events = context.watch<BmsDashboardProvider>().telemetry.events;
    return BmsPanel(
      title: 'Recent events log',
      trailing: Text(
        '${events.length} EVENTS',
        style: const TextStyle(
          color: BmsColors.muted,
          fontSize: 9,
          letterSpacing: .4,
        ),
      ),
      child: events.isEmpty
          ? const Text(
              'No recent events reported by the gateway.',
              style: TextStyle(color: BmsColors.muted, fontSize: 11),
            )
          : Column(
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  Row(
                    children: [
                      Icon(
                        _iconFor(events[i].kind),
                        size: 15,
                        color: BmsColors.muted,
                      ),
                      const SizedBox(width: 9),
                      Text(
                        events[i].time,
                        style: const TextStyle(
                          color: BmsColors.muted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          events[i].message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (i < events.length - 1)
                    const Divider(height: 16, color: BmsColors.border),
                ],
              ],
            ),
    );
  }
}

class BmsTrendPanel extends StatelessWidget {
  const BmsTrendPanel({super.key, this.height = 175});
  final double height;

  static const _soc = [70, 71, 70.5, 72, 73, 72.4, 75, 76, 75.5, 78];
  static const _voltage = [736, 738, 737, 739, 741, 740, 742, 741, 743, 742.6];
  static const _soc6h = [66, 67, 67.5, 69, 70, 71, 73, 74, 76, 78];
  static const _voltage6h = [
    731,
    733,
    735,
    734,
    738,
    739,
    741,
    742,
    741,
    742.6,
  ];
  static const _soc24h = [58, 57, 60, 62, 65, 64, 69, 72, 75, 78];
  static const _voltage24h = [
    728,
    729,
    732,
    734,
    733,
    737,
    739,
    741,
    740,
    742.6,
  ];

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BmsDashboardProvider>();
    final data = model.telemetry;
    final socSeries = model.trendRange == '24H'
        ? _soc24h
        : model.trendRange == '6H'
        ? _soc6h
        : _soc;
    final voltageSeries = model.trendRange == '24H'
        ? _voltage24h
        : model.trendRange == '6H'
        ? _voltage6h
        : _voltage;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TrendPainter(
          values: socSeries.map((value) => value / 100).toList(),
          color: BmsColors.teal,
          secondaryValues: voltageSeries
              .map((value) => (value - 730) / 20)
              .toList(),
          secondaryColor: BmsColors.warning,
          currentSoc: data.soc / 100,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  const _TrendPainter({
    required this.values,
    required this.color,
    required this.secondaryValues,
    required this.secondaryColor,
    required this.currentSoc,
  });

  final List<double> values;
  final Color color;
  final List<double> secondaryValues;
  final Color secondaryColor;
  final double currentSoc;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 8.0;
    final chart = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final gridPaint = Paint()
      ..color = BmsColors.border.withValues(alpha: .7)
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
    }
    void drawSeries(
      List<double> points,
      Color seriesColor, {
      bool fill = false,
    }) {
      if (points.length < 2) return;
      final path = Path();
      for (var i = 0; i < points.length; i++) {
        final x = chart.left + chart.width * i / (points.length - 1);
        final y =
            chart.bottom - points[i].clamp(0.0, 1.0).toDouble() * chart.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          final prevX =
              chart.left + chart.width * (i - 1) / (points.length - 1);
          final prevY =
              chart.bottom -
              points[i - 1].clamp(0.0, 1.0).toDouble() * chart.height;
          final mid = (prevX + x) / 2;
          path.cubicTo(mid, prevY, mid, y, x, y);
        }
      }
      if (fill) {
        final fillPath = Path.from(path)
          ..lineTo(chart.right, chart.bottom)
          ..lineTo(chart.left, chart.bottom)
          ..close();
        canvas.drawPath(
          fillPath,
          Paint()
            ..shader = LinearGradient(
              colors: [
                seriesColor.withValues(alpha: .22),
                seriesColor.withValues(alpha: .01),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ).createShader(chart),
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = seriesColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );
    }

    drawSeries(secondaryValues, secondaryColor);
    drawSeries(values, color, fill: true);
    final dot = Offset(
      chart.right,
      chart.bottom - currentSoc.clamp(0.0, 1.0).toDouble() * chart.height,
    );
    canvas.drawCircle(dot, 4, Paint()..color = color);
    canvas.drawCircle(dot, 7, Paint()..color = color.withValues(alpha: .16));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter oldDelegate) =>
      oldDelegate.currentSoc != currentSoc ||
      oldDelegate.values != values ||
      oldDelegate.secondaryValues != secondaryValues;
}

class _Sparkline extends StatelessWidget {
  const _Sparkline();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _SparklinePainter(), child: const SizedBox.expand());
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const samples = [
      .46,
      .4,
      .55,
      .36,
      .51,
      .25,
      .37,
      .16,
      .27,
      .12,
      .32,
      .19,
      .42,
      .22,
      .49,
      .31,
      .58,
      .37,
    ];
    final path = Path();
    for (var i = 0; i < samples.length; i++) {
      final x = size.width * i / (samples.length - 1);
      final y = size.height * samples[i];
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x66FF9100), Color(0x05FF9100)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = BmsColors.warning
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => false;
}

class _TempSummary extends StatelessWidget {
  const _TempSummary({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: .5,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        '${value.toStringAsFixed(0)}°C',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ],
  );
}

class _FaultCount extends StatelessWidget {
  const _FaultCount({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$count',
        style: TextStyle(
          color: color,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          color: BmsColors.muted,
          fontSize: 8,
          letterSpacing: .5,
        ),
      ),
    ],
  );
}

class _ScaleLabel extends StatelessWidget {
  const _ScaleLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label, style: const TextStyle(color: BmsColors.muted, fontSize: 9));
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bms_telemetry.dart';
import '../services/auth_controller.dart';
import '../services/bms_dashboard_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/dashboard_cards.dart';

Widget _pageFrame(Widget child) => SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
  child: Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1120),
      child: child,
    ),
  ),
);

class FaultsView extends StatelessWidget {
  const FaultsView({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BmsDashboardProvider>();
    final alerts = model.activeAlerts;
    return _pageFrame(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ViewHeading(
            kicker: 'PROTECTION',
            title: 'Faults & alerts',
            subtitle: 'Active conditions reported by the current data source.',
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: _CountPanel(
                      title: 'Warnings',
                      count: model.warningCount,
                      color: BmsColors.warning,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _CountPanel(
                      title: 'Critical faults',
                      count: model.criticalCount,
                      color: BmsColors.critical,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          BmsPanel(
            title: 'Active conditions',
            trailing: BmsStatusPill(
              label: alerts.isEmpty ? 'ALL CLEAR' : '${alerts.length} ACTIVE',
              color: alerts.isEmpty ? BmsColors.healthy : BmsColors.warning,
            ),
            child: alerts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 44,
                            color: BmsColors.healthy,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'NO ACTIVE FAULTS OR ALERTS',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: .4,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'No active conditions are present in the current sample.',
                            style: TextStyle(
                              color: BmsColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final alert in alerts) _AlertRow(alert: alert),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Prototype note: simulated alerts are for interface review only and are not battery protection commands.',
            style: TextStyle(color: BmsColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class TrendsView extends StatelessWidget {
  const TrendsView({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BmsDashboardProvider>();
    final data = model.telemetry;
    return _pageFrame(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ViewHeading(
            kicker: 'TELEMETRY HISTORY',
            title: 'Trends',
            subtitle:
                'Illustrative sample history for pack state and bus voltage.',
          ),
          const SizedBox(height: 16),
          BmsPanel(
            title: 'Pack trends',
            trailing: BmsStatusPill(
              label: 'DEMO SERIES',
              color: BmsColors.teal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 7,
                  children: ['1H', '6H', '24H']
                      .map(
                        (range) => ChoiceChip(
                          label: Text(
                            range,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          selected: model.trendRange == range,
                          onSelected: (_) => model.setTrendRange(range),
                          selectedColor: BmsColors.teal.withValues(alpha: .22),
                          backgroundColor: BmsColors.shell,
                          side: BorderSide(
                            color: model.trendRange == range
                                ? BmsColors.teal
                                : BmsColors.border,
                          ),
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 15),
                const BmsTrendPanel(height: 250),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    _LegendDot(color: BmsColors.teal, label: 'State of charge'),
                    SizedBox(width: 18),
                    _LegendDot(
                      color: BmsColors.warning,
                      label: 'Voltage trend',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BmsPanel(
            title: 'Current snapshot',
            child: Row(
              children: [
                Expanded(
                  child: BmsMetric(
                    value: data.soc.toStringAsFixed(0),
                    unit: '%',
                    label: 'SOC',
                  ),
                ),
                Expanded(
                  child: BmsMetric(
                    value: data.packVoltageV.toStringAsFixed(1),
                    unit: 'V',
                    label: 'Pack voltage',
                  ),
                ),
                Expanded(
                  child: BmsMetric(
                    value: data.avgTempC.toStringAsFixed(0),
                    unit: '°C',
                    label: 'Average temperature',
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

class CellsView extends StatelessWidget {
  const CellsView({super.key});

  @override
  Widget build(BuildContext context) {
    final cells = context.watch<BmsDashboardProvider>().telemetry.cells;
    return _pageFrame(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ViewHeading(
            kicker: 'CELL MONITORING',
            title: 'Cell overview',
            subtitle: 'Representative sample values for the cell view.',
          ),
          const SizedBox(height: 16),
          BmsPanel(
            title: 'Cell readings',
            trailing: BmsStatusPill(
              label: '${cells.length} CELLS',
              color: BmsColors.teal,
            ),
            child: cells.isEmpty
                ? const Text(
                    'No cell-level readings have been reported by the current gateway.',
                    style: TextStyle(color: BmsColors.muted, fontSize: 12),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 760
                          ? 4
                          : constraints.maxWidth >= 480
                          ? 3
                          : 2;
                      final gap = 10.0;
                      final tileWidth =
                          (constraints.maxWidth - gap * (columns - 1)) /
                          columns;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: cells
                            .map(
                              (cell) => SizedBox(
                                width: tileWidth,
                                child: _CellTile(cell: cell),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cell-level readings are simulated until a gateway provides a validated cell schema.',
            style: TextStyle(color: BmsColors.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BmsDashboardProvider>();
    final auth = context.watch<AuthController>();
    return _pageFrame(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ViewHeading(
            kicker: 'PREFERENCES',
            title: 'Settings',
            subtitle: 'Prototype data source and display information.',
          ),
          const SizedBox(height: 16),
          BmsPanel(
            title: 'Authenticated session',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final operator = Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: BmsColors.healthy, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BmsInfoRow(
                        label: 'Operator',
                        value: auth.email ?? 'Verified session',
                        valueColor: BmsColors.healthy,
                      ),
                    ),
                  ],
                );
                final signOut = OutlinedButton.icon(
                  onPressed: auth.logout,
                  icon: const Icon(Icons.logout_rounded, size: 15),
                  label: const Text('Sign out'),
                );
                if (constraints.maxWidth < 500) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [operator, const SizedBox(height: 8), signOut],
                  );
                }
                return Row(children: [Expanded(child: operator), const SizedBox(width: 10), signOut]);
              },
            ),
          ),
          const SizedBox(height: 12),
          BmsPanel(
            title: 'Data source',
            child: Column(
              children: [
                BmsInfoRow(
                  label: 'Gateway',
                  value: model.telemetry.gatewayName,
                ),
                BmsInfoRow(
                  label: 'Transport',
                  value: model.isLive
                      ? 'WebSocket'
                      : model.isTelemetryStale
                      ? 'WebSocket disconnected'
                      : 'Demo stream',
                  valueColor: model.isLive
                      ? BmsColors.healthy
                      : model.isTelemetryStale
                      ? BmsColors.warning
                      : BmsColors.teal,
                ),
                BmsInfoRow(
                  label: 'Data status',
                  value: model.sourceLabel,
                  valueColor: model.isLive
                      ? BmsColors.healthy
                      : model.isTelemetryStale
                      ? BmsColors.warning
                      : BmsColors.teal,
                ),
                BmsInfoRow(
                  label: 'Refresh interval',
                  value: model.isLive
                      ? 'Gateway controlled'
                      : model.isTelemetryStale
                      ? 'Stopped — stale reading'
                      : '5 seconds (demo)',
                ),
                const Divider(height: 22, color: BmsColors.border),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Simulate warning alert',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Preview warning-state styling only. Does not control hardware.',
                            style: TextStyle(
                              color: BmsColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Switch.adaptive(
                      activeTrackColor: BmsColors.warning,
                      value: model.simulatedWarning,
                      onChanged: model.isLive
                          ? null
                          : model.setSimulatedWarning,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const BmsPanel(
            title: 'Gateway integration',
            child: Text(
              'A browser WebSocket adapter is available when a gateway endpoint is supplied at build/run time. The gateway message schema, authentication, TLS, allowed origins, and reconnect rules must be confirmed by the system owner. MQTT can be added behind the same adapter boundary after broker details are available.',
              style: TextStyle(
                color: BmsColors.muted,
                fontSize: 12,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const BmsPanel(
            title: 'Display profile',
            child: BmsInfoRow(label: 'Theme', value: 'Dark industrial'),
          ),
        ],
      ),
    );
  }
}

class _ViewHeading extends StatelessWidget {
  const _ViewHeading({
    required this.kicker,
    required this.title,
    required this.subtitle,
  });
  final String kicker;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        kicker,
        style: const TextStyle(
          color: BmsColors.teal,
          fontSize: 9,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 5),
      Text(
        title,
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w800,
          letterSpacing: -.4,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(color: BmsColors.muted, fontSize: 12),
      ),
    ],
  );
}

class _CountPanel extends StatelessWidget {
  const _CountPanel({
    required this.title,
    required this.count,
    required this.color,
  });
  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) => BmsPanel(
    title: title,
    child: Row(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 34,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            count == 0 ? 'No active conditions' : 'Active items require review',
            style: const TextStyle(color: BmsColors.muted, fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.alert});
  final BmsAlert alert;

  @override
  Widget build(BuildContext context) {
    final color = alert.severity == AlertSeverity.critical
        ? BmsColors.critical
        : BmsColors.warning;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            alert.severity == AlertSeverity.critical
                ? Icons.error_rounded
                : Icons.warning_amber_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  alert.detail,
                  style: const TextStyle(color: BmsColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            alert.time,
            style: const TextStyle(color: BmsColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CellTile extends StatelessWidget {
  const _CellTile({required this.cell});
  final CellReading cell;

  @override
  Widget build(BuildContext context) {
    final hot = cell.temperatureC >= 32;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BmsColors.shell.withValues(alpha: .6),
        border: Border.all(
          color: hot
              ? BmsColors.warning.withValues(alpha: .5)
              : BmsColors.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  cell.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              if (cell.balancing)
                const Icon(
                  Icons.balance_rounded,
                  size: 14,
                  color: BmsColors.teal,
                ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '${cell.voltageV.toStringAsFixed(3)} V',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${cell.temperatureC.toStringAsFixed(0)} °C',
            style: TextStyle(
              color: hot ? BmsColors.warning : BmsColors.muted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: ((cell.voltageV - 3.2) / .4).clamp(0.0, 1.0),
            minHeight: 3,
            backgroundColor: BmsColors.border,
            color: hot ? BmsColors.warning : BmsColors.teal,
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: BmsColors.muted, fontSize: 10)),
    ],
  );
}

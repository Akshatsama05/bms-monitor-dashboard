import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_controller.dart';
import '../services/bms_dashboard_provider.dart';
import '../theme/app_theme.dart';

class BmsAppHeader extends StatelessWidget {
  const BmsAppHeader({super.key});

  String _clock(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';

  String _month(int month) => const [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ][month - 1];

  @override
  Widget build(BuildContext context) {
    final headerState = context.select<BmsDashboardProvider, ({DateTime now, DateTime timestamp, bool stale, bool live, String connection, String gateway})>(
      (provider) => (
        now: provider.now,
        timestamp: provider.telemetry.timestamp,
        stale: provider.isTelemetryStale,
        live: provider.isLive,
        connection: provider.connectionLabel,
        gateway: provider.telemetry.gatewayName,
      ),
    );

    return Material(
      color: BmsColors.shell,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 820;
            final syncText = _clock(headerState.timestamp.toLocal());
            final statusColor = headerState.stale
                ? BmsColors.warning
                : headerState.live || headerState.connection == 'CONNECTED • DEMO'
                ? BmsColors.healthy
                : BmsColors.teal;
            return Container(
              height: narrow ? 82 : 66,
              padding: EdgeInsets.symmetric(
                horizontal: narrow ? 14 : 22,
                vertical: 8,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: BmsColors.border, width: .8),
                ),
              ),
              child: narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const _BatteryMark(size: 30),
                              const SizedBox(width: 9),
                              const Text(
                                'BMS MONITOR',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .7,
                                ),
                              ),
                              const Spacer(),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(_clock(headerState.now), style: _clockStyle),
                                  Text(_date(headerState.now), style: _metaStyle),
                                ],
                              ),
                              if (constraints.maxWidth >= 430)
                                _logoutButton(context),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _StatusDot(color: statusColor),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                headerState.gateway,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: _gatewayStyle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusPill(
                              headerState.connection,
                              color: statusColor,
                            ),
                            if (constraints.maxWidth >= 430) ...[
                              const SizedBox(width: 10),
                              Text('SYNC $syncText', style: _metaStyle),
                            ],
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        const _BatteryMark(size: 36),
                        const SizedBox(width: 10),
                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMS MONITOR',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .8,
                              ),
                            ),
                            Text(
                              'BATTERY SYSTEMS',
                              style: TextStyle(
                                color: BmsColors.muted,
                                fontSize: 9,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 22),
                        Container(
                          width: 1,
                          height: 42,
                          color: BmsColors.border,
                        ),
                        const SizedBox(width: 20),
                        _StatusDot(color: statusColor),
                        const SizedBox(width: 9),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                            headerState.gateway,
                              style: _gatewayStyle,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _statusPill(
                                  headerState.connection,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 8),
                                Text('Last sync $syncText', style: _metaStyle),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_clock(headerState.now), style: _clockStyle),
                            const SizedBox(height: 3),
                            Text(_date(headerState.now), style: _metaStyle),
                          ],
                        ),
                        _logoutButton(context),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _logoutButton(BuildContext context) => IconButton(
    tooltip: 'Sign out',
    onPressed: () => context.read<AuthController>().logout(),
    icon: const Icon(Icons.logout_rounded, size: 18),
    color: BmsColors.muted,
  );

  Widget _statusPill(String label, {required Color color}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: color.withValues(alpha: .3)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: .5,
      ),
    ),
  );
}

const _gatewayStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  letterSpacing: .5,
);
const _metaStyle = TextStyle(color: BmsColors.muted, fontSize: 10);
const _clockStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _BatteryMark extends StatelessWidget {
  const _BatteryMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(size, size), painter: _BatteryMarkPainter());
}

class _BatteryMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = BmsColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .08;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * .12,
        size.height * .2,
        size.width * .72,
        size.height * .62,
      ),
      Radius.circular(size.width * .12),
    );
    canvas.drawRRect(body, stroke);
    final terminal = Paint()..color = BmsColors.teal;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * .84,
          size.height * .39,
          size.width * .1,
          size.height * .22,
        ),
        Radius.circular(size.width * .04),
      ),
      terminal,
    );
    final bolt = Path()
      ..moveTo(size.width * .56, size.height * .28)
      ..lineTo(size.width * .35, size.height * .54)
      ..lineTo(size.width * .49, size.height * .54)
      ..lineTo(size.width * .42, size.height * .74)
      ..lineTo(size.width * .68, size.height * .45)
      ..lineTo(size.width * .53, size.height * .45)
      ..close();
    canvas.drawPath(bolt, Paint()..color = BmsColors.healthy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

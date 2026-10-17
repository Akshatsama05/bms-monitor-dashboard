import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/dashboard_cards.dart';

class OverviewView extends StatelessWidget {
  const OverviewView({super.key});

  List<Widget> _leftColumn() => const [
    SocCard(),
    SizedBox(height: 14),
    TemperatureCard(),
  ];

  List<Widget> _middleColumn() => const [
    PackMeasurementsCard(),
    SizedBox(height: 14),
    SystemStatusCard(),
    SizedBox(height: 14),
    FaultsCard(),
  ];

  List<Widget> _rightColumn() => const [
    HealthCard(),
    SizedBox(height: 14),
    RecentEventsCard(),
  ];

  List<Widget> _allCards() => [
    ..._leftColumn(),
    const SizedBox(height: 14),
    ..._middleColumn(),
    const SizedBox(height: 14),
    ..._rightColumn(),
  ];

  Widget _scrollColumn(List<Widget> children) => Expanded(
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(children: children),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = math.min(constraints.maxWidth, viewportWidth);
        if (availableWidth >= 980) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _scrollColumn(_leftColumn()),
                const SizedBox(width: 14),
                _scrollColumn(_middleColumn()),
                const SizedBox(width: 14),
                _scrollColumn(_rightColumn()),
              ],
            ),
          );
        }
        if (availableWidth >= 650) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _scrollColumn([
                  ..._leftColumn(),
                  const SizedBox(height: 14),
                  ..._middleColumn(),
                ]),
                const SizedBox(width: 14),
                _scrollColumn([
                  ..._rightColumn(),
                  const SizedBox(height: 14),
                  const FaultsCard(),
                ]),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          child: Column(children: _allCards()),
        );
      },
    );
  }
}

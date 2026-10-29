import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/bms_dashboard_provider.dart';
import 'overview_view.dart';
import 'secondary_views.dart';

class DashboardViewRouter extends StatelessWidget {
  const DashboardViewRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final index = context.select<BmsDashboardProvider, int>((provider) => provider.selectedTab);
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 180);
    final Widget page = switch (index) {
      1 => const FaultsView(),
      2 => const TrendsView(),
      3 => const CellsView(),
      4 => const SettingsView(),
      _ => const OverviewView(),
    };

    return AnimatedSwitcher(
      duration: duration,
      child: KeyedSubtree(key: ValueKey<int>(index), child: page),
    );
  }
}

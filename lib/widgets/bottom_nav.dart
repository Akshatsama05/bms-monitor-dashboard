import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/bms_dashboard_provider.dart';
import '../theme/app_theme.dart';

class BmsBottomNavigation extends StatelessWidget {
  const BmsBottomNavigation({super.key});

  static const _items = <({String label, IconData icon})>[
    (label: 'Overview', icon: Icons.home_outlined),
    (label: 'Faults', icon: Icons.warning_amber_rounded),
    (label: 'Trends', icon: Icons.show_chart_rounded),
    (label: 'Cells', icon: Icons.battery_4_bar_rounded),
    (label: 'Settings', icon: Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select<BmsDashboardProvider, int>((provider) => provider.selectedTab);
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 160);
    return Material(
      color: BmsColors.shell,
      child: SafeArea(
        top: false,
        child: Container(
          height: 62,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: BmsColors.border, width: .8)),
          ),
          child: Row(
            children: List<Widget>.generate(_items.length, (index) {
              final item = _items[index];
              final selected = selectedTab == index;
              final accent = selected ? BmsColors.blue : BmsColors.muted;
              return Expanded(
                  child: InkWell(
                  onTap: () => context.read<BmsDashboardProvider>().selectTab(index),
                  child: AnimatedContainer(
                    duration: duration,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: selected ? BmsColors.blue : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      color: selected
                          ? BmsColors.blue.withValues(alpha: .06)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 20, color: accent),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

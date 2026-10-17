import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'views/dashboard_view.dart';
import 'widgets/app_header.dart';
import 'widgets/bottom_nav.dart';

class BmsMonitorApp extends StatelessWidget {
  const BmsMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMS Monitor Dashboard',
      debugShowCheckedModeBanner: false,
      theme: buildBmsTheme(),
      home: const BmsDashboardShell(),
    );
  }
}

class BmsDashboardShell extends StatelessWidget {
  const BmsDashboardShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BmsColors.background,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(82),
        child: BmsAppHeader(),
      ),
      body: const DashboardViewRouter(),
      bottomNavigationBar: const BmsBottomNavigation(),
    );
  }
}

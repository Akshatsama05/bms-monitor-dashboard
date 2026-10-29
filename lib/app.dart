import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_controller.dart';
import 'theme/app_theme.dart';
import 'views/auth_view.dart';
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
      home: const _AuthRouter(),
    );
  }
}

class _AuthRouter extends StatelessWidget {
  const _AuthRouter();

  @override
  Widget build(BuildContext context) {
    final status = context.watch<AuthController>().status;
    return switch (status) {
      AuthStatus.loading => const _AuthLoadingScreen(),
      AuthStatus.authenticated => const BmsDashboardShell(),
      AuthStatus.error || AuthStatus.signedOut || AuthStatus.needsVerification => const AuthView(),
    };
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: BmsColors.shell,
    body: Center(child: CircularProgressIndicator(color: BmsColors.teal)),
  );
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

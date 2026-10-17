import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/bms_dashboard_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BmsDashboardProvider(),
      child: const BmsMonitorApp(),
    ),
  );
}

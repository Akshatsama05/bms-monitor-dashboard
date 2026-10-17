import 'package:flutter/material.dart';

abstract final class BmsColors {
  static const shell = Color(0xFF121512);
  static const background = Color(0xFF191D1C);
  static const card = Color(0xFF222726);
  static const cardRaised = Color(0xFF292F2E);
  static const border = Color(0xFF3B4542);
  static const text = Color(0xFFF3F6F5);
  static const muted = Color(0xFF9AA6A2);
  static const dim = Color(0xFF6E7A76);
  static const healthy = Color(0xFF00C853);
  static const warning = Color(0xFFFF9100);
  static const critical = Color(0xFFD50000);
  static const teal = Color(0xFF27C7BC);
  static const tealDeep = Color(0xFF137E79);
  static const blue = Color(0xFF67A9FF);
}

ThemeData buildBmsTheme() {
  const colorScheme = ColorScheme.dark(
    primary: BmsColors.teal,
    secondary: BmsColors.healthy,
    surface: BmsColors.card,
    error: BmsColors.critical,
    onPrimary: BmsColors.shell,
    onSecondary: BmsColors.shell,
    onSurface: BmsColors.text,
    onError: BmsColors.text,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: BmsColors.background,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: BmsColors.text, fontSize: 14),
      bodySmall: TextStyle(color: BmsColors.muted, fontSize: 12),
      titleMedium: TextStyle(
        color: BmsColors.text,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerColor: BmsColors.border,
    splashColor: BmsColors.teal.withValues(alpha: .08),
    highlightColor: BmsColors.teal.withValues(alpha: .06),
  );
}

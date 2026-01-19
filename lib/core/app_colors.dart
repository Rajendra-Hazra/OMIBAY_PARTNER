import 'package:flutter/material.dart';

class AppColors {
  // Primary Gradients
  static const Color primaryOrangeStart = Color(0xFFFF7A00);
  static const Color primaryOrangeEnd = Color(0xFFFF9500);

  static const Color darkNavyStart = Color(0xFF0A192F);
  static const Color darkNavyEnd = Color(0xFF112240);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color successGreenAlt = Color(0xFF22C55E);

  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedAlt = Color(0xFFDC2626);

  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color warningYellowAlt = Color(0xFFEAB308);

  // Backgrounds
  static const Color bgStart = Color(0xFFF5F7FA);
  static const Color bgWhite = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF0A192F);
  static const Color textSecondary = Color(0xFF64748B);

  // Borders
  static const Color border = Color(0x1A000000); // rgba(0, 0, 0, 0.1)

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryOrangeStart, primaryOrangeEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkNavyStart, darkNavyEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgStart, bgWhite],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Global Notifiers
  static final ValueNotifier<int> profileUpdateNotifier = ValueNotifier(0);
  static final ValueNotifier<int> unreadNotificationsNotifier = ValueNotifier(
    2,
  ); // Mock 2 unread by default
  static final ValueNotifier<int> jobUpdateNotifier = ValueNotifier(0);
}

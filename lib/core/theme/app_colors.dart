import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Professional Black & White Theme
  static const Color primary = Color(0xFF000000); // Pure Black
  static const Color secondary = Color(0xFF2C2C2C); // Dark Charcoal
  static const Color accent = Color(0xFF404040); // Medium Gray

  static const Color background = Color(0xFFFAFAFA); // Off White
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color cardBackground = Color(0xFFF5F5F5); // Light Gray

  static const Color textPrimary = Color(0xFF000000); // Black Text
  static const Color textSecondary = Color(0xFF666666); // Gray Text
  static const Color textTertiary = Color(0xFF999999); // Light Gray Text

  static const Color success = Color(0xFF2E7D32); // Dark Green
  static const Color warning = Color(0xFFE65100); // Orange
  static const Color error = Color(0xFFD32F2F); // Red

  static const Color border = Color(0xFFE0E0E0); // Light Border
  static const Color divider = Color(0xFFEEEEEE); // Divider
}

class AppGradients {
  // Professional gradient for buttons
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.secondary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.surface, AppColors.cardBackground],
  );
}

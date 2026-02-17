import 'package:flutter/material.dart';

class AppColors {
  // Background colors
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color splashBackground = Color(0xFF0A1929);

  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);

  // Semantic colors
  static const Color success = Color(0xFF4CAF50); // Green - compliant
  static const Color warning = Color(0xFFFFC107); // Yellow - partial
  static const Color error = Color(0xFFF44336); // Red - non-compliant
  static const Color critical = Color(0xFFD32F2F); // Dark red

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textDisabled = Color(0xFF757575);

  // Status overlay colors (with transparency)
  static final Color compliantOverlay = success.withOpacity(0.3);
  static final Color partialOverlay = warning.withOpacity(0.3);
  static final Color violationOverlay = error.withOpacity(0.3);
}

import 'package:flutter/material.dart';

/// SafeSight unified brand palette — modern **dark blue / navy** on a dark theme.
/// Semantic colors (success/warning/error) are kept distinct from the brand blue.
class AppColors {
  // Brand (dark blue / navy)
  static const Color primary = Color(0xFF2563EB); // brand blue
  static const Color primaryDark = Color(0xFF1E3A8A); // deep navy
  static const Color accent = Color(0xFF3B82F6); // lighter blue accent

  // Backgrounds (deep navy-tinted dark)
  static const Color background = Color(0xFF0B1220);
  static const Color cardBackground = Color(0xFF131C2E);
  static const Color surface = Color(0xFF1B2740);
  static const Color splashBackground = Color(0xFF0A1A33);

  // Borders / dividers
  static const Color border = Color(0xFF26344F);

  // Semantic colors (kept clearly distinct from the blue brand)
  static const Color success = Color(0xFF22C55E); // green - compliant
  static const Color warning = Color(0xFFF59E0B); // amber - partial
  static const Color error = Color(0xFFEF4444); // red - non-compliant
  static const Color critical = Color(0xFFB91C1C); // dark red

  // Text
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF64748B);

  // Status overlay colors (with transparency)
  static final Color compliantOverlay = success.withOpacity(0.3);
  static final Color partialOverlay = warning.withOpacity(0.3);
  static final Color violationOverlay = error.withOpacity(0.3);

  // Brand gradient (navy -> blue) for headers, buttons, splash.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  // Subtle elevated-card gradient.
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF15203A), Color(0xFF111A2C)],
  );
}

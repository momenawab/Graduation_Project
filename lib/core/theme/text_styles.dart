import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTextStyles {
  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textDisabled,
    height: 1.3,
  );

  // Caption styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textDisabled,
    height: 1.2,
  );

  // Button styles
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    height: 1.2,
  );

  // Label styles
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Error styles
  static const TextStyle error = TextStyle(
    fontSize: 12,
    color: AppColors.error,
    height: 1.3,
  );

  // Success styles
  static const TextStyle success = TextStyle(
    fontSize: 12,
    color: AppColors.success,
    height: 1.3,
  );
}

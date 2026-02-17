import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';

/// Standard button widget with text, icon, and loading state variants.
@immutable
class AppButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Optional icon
  final IconData? icon;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button is disabled
  final bool isDisabled;

  /// Button background color (defaults to primary color)
  final Color? backgroundColor;

  /// Button text color
  final Color? textColor;

  /// Button onPressed callback
  final VoidCallback? onPressed;

  /// Button width (optional)
  final double? width;

  /// Button height (optional)
  final double? height;

  const AppButton({
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.textColor,
    this.onPressed,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isDisabled
        ? AppColors.textDisabled
        : backgroundColor ?? AppColors.primary;

    final effectiveTextColor = textColor ?? Colors.white;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: AppColors.textDisabled,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

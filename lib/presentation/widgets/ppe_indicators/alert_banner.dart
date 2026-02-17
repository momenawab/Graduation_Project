import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/alert_config.dart';

/// Widget for displaying alert banner with dismiss functionality.
@immutable
class AlertBanner extends StatelessWidget {
  /// Alert type to display
  final AlertType alertType;

  /// Alert message text
  final String message;

  /// Whether alert is critical (uses different styling)
  final bool isCritical;

  /// Callback when banner is dismissed
  final VoidCallback? onDismiss;

  /// Optional action button text
  final String? actionText;

  /// Callback when action button is pressed
  final VoidCallback? onAction;

  /// Banner padding (defaults to horizontal 16, vertical 12)
  final EdgeInsetsGeometry? padding;

  /// Custom icon (overrides default)
  final IconData? customIcon;

  const AlertBanner({
    required this.alertType,
    required this.message,
    this.isCritical = false,
    this.onDismiss,
    this.actionText,
    this.onAction,
    this.padding,
    this.customIcon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfig();

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        border: Border.all(color: config.borderColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(customIcon ?? config.icon, color: config.iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getAlertTitle(),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null || onAction != null) ...[
            const SizedBox(width: 12),
            if (onDismiss != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onDismiss,
                color: AppColors.textSecondary,
              ),
            if (onAction != null && actionText != null)
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _getAlertTitle() {
    switch (alertType) {
      case AlertType.ppeCompliance:
        return 'PPE Compliance Alert';
      case AlertType.proxWarning:
        return 'Proximity Warning';
      case AlertType.stealthMode:
        return 'Stealth Mode Alert';
      case AlertType.zoneIncursion:
        return 'Zone Incursion Alert';
      case AlertType.safetyMetrics:
        return 'Safety Metrics Alert';
      case AlertType.systemStatus:
        return 'System Status Alert';
    }
  }

  _AlertConfig _getAlertConfig() {
    final baseConfig = switch (alertType) {
      AlertType.ppeCompliance => _AlertConfig(
        backgroundColor: AppColors.error.withOpacity(0.1),
        borderColor: AppColors.error,
        icon: Icons.warning,
        iconColor: AppColors.error,
      ),
      AlertType.proxWarning => _AlertConfig(
        backgroundColor: AppColors.warning.withOpacity(0.1),
        borderColor: AppColors.warning,
        icon: Icons.warning_amber,
        iconColor: AppColors.warning,
      ),
      AlertType.stealthMode => _AlertConfig(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        borderColor: AppColors.primary,
        icon: Icons.visibility_off,
        iconColor: AppColors.primary,
      ),
      AlertType.zoneIncursion => _AlertConfig(
        backgroundColor: AppColors.error.withOpacity(0.1),
        borderColor: AppColors.error,
        icon: Icons.location_off,
        iconColor: AppColors.error,
      ),
      AlertType.safetyMetrics => _AlertConfig(
        backgroundColor: AppColors.warning.withOpacity(0.1),
        borderColor: AppColors.warning,
        icon: Icons.analytics,
        iconColor: AppColors.warning,
      ),
      AlertType.systemStatus => _AlertConfig(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        borderColor: AppColors.primary,
        icon: Icons.info,
        iconColor: AppColors.primary,
      ),
    };

    if (isCritical) {
      return _AlertConfig(
        backgroundColor: AppColors.critical.withOpacity(0.2),
        borderColor: AppColors.critical,
        icon: Icons.error,
        iconColor: AppColors.critical,
      );
    }

    return baseConfig;
  }
}

@immutable
class _AlertConfig {
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;

  const _AlertConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
  });
}

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';

/// Status badge widget for displaying compliance or system status.
@immutable
class StatusBadge extends StatelessWidget {
  /// Badge text label
  final String label;

  /// Badge status type
  final StatusType status;

  /// Whether to show icon (defaults to true)
  final bool showIcon;

  /// Badge padding (defaults to horizontal 12, vertical 6)
  final EdgeInsetsGeometry? padding;

  /// Badge border radius (defaults to 16)
  final double borderRadius;

  /// Custom icon size (defaults to 16)
  final double? iconSize;

  /// Custom text style
  final TextStyle? textStyle;

  const StatusBadge({
    required this.label,
    required this.status,
    this.showIcon = true,
    this.padding,
    this.borderRadius = 16,
    this.iconSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, color: config.textColor, size: iconSize ?? 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style:
                (textStyle ??
                        const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ))
                    .copyWith(color: config.textColor),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig() {
    switch (status) {
      case StatusType.success:
        return _StatusConfig(
          backgroundColor: AppColors.success,
          textColor: Colors.white,
          icon: Icons.check_circle,
        );
      case StatusType.warning:
        return _StatusConfig(
          backgroundColor: AppColors.warning,
          textColor: Colors.white,
          icon: Icons.warning,
        );
      case StatusType.error:
        return _StatusConfig(
          backgroundColor: AppColors.error,
          textColor: Colors.white,
          icon: Icons.error,
        );
      case StatusType.info:
        return _StatusConfig(
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          icon: Icons.info,
        );
      case StatusType.neutral:
        return _StatusConfig(
          backgroundColor: AppColors.textSecondary,
          textColor: Colors.white,
          icon: Icons.circle,
        );
    }
  }
}

/// Status type enum for badge styling.
enum StatusType {
  /// Success/compliant status (green)
  success,

  /// Warning/partial compliance status (yellow)
  warning,

  /// Error/non-compliant status (red)
  error,

  /// Info status (blue)
  info,

  /// Neutral status (gray)
  neutral,
}

@immutable
class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
  });
}

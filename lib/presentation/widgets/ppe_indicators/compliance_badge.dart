import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/detection_result.dart';

/// Widget for displaying compliance status badge with icon and percentage.
@immutable
class ComplianceBadge extends StatelessWidget {
  /// Compliance status to display
  final ComplianceStatus status;

  /// Compliance percentage (0-100)
  final int compliancePercentage;

  /// Badge size (defaults to 80)
  final double size;

  /// Whether to show percentage (defaults to true)
  final bool showPercentage;

  /// Custom label text (overrides default)
  final String? customLabel;

  const ComplianceBadge({
    required this.status,
    required this.compliancePercentage,
    this.size = 80,
    this.showPercentage = true,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: config.backgroundColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icon, color: Colors.white, size: size * 0.35),
          const SizedBox(height: 4),
          if (showPercentage) ...[
            Text(
              '$compliancePercentage%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (customLabel != null) ...[
            Text(
              customLabel!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  _ComplianceConfig _getStatusConfig() {
    switch (status) {
      case ComplianceStatus.compliant:
        return _ComplianceConfig(
          backgroundColor: AppColors.success,
          icon: Icons.check_circle,
        );
      case ComplianceStatus.partial:
        return _ComplianceConfig(
          backgroundColor: AppColors.warning,
          icon: Icons.warning,
        );
      case ComplianceStatus.nonCompliant:
        return _ComplianceConfig(
          backgroundColor: AppColors.error,
          icon: Icons.error,
        );
      case ComplianceStatus.unknown:
        return _ComplianceConfig(
          backgroundColor: AppColors.error,
          icon: Icons.error,
        );
    }
  }
}

@immutable
class _ComplianceConfig {
  final Color backgroundColor;
  final IconData icon;

  const _ComplianceConfig({required this.backgroundColor, required this.icon});
}

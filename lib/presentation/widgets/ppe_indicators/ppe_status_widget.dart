import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/ppe_item.dart';

/// Widget for displaying PPE status with icon and color coding.
@immutable
class PPEStatusWidget extends StatelessWidget {
  /// PPE item to display
  final PPEItem ppeItem;

  /// Widget size (defaults to 48)
  final double size;

  /// Whether to show label (defaults to true)
  final bool showLabel;

  /// Custom label text (overrides default)
  final String? customLabel;

  const PPEStatusWidget({
    required this.ppeItem,
    this.size = 48,
    this.showLabel = true,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: config.backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: config.backgroundColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(config.icon, color: Colors.white, size: size * 0.5),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            customLabel ?? _getDefaultLabel(),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  _PPEStatusConfig _getStatusConfig() {
    switch (ppeItem.status) {
      case PPEStatus.compliant:
        return _PPEStatusConfig(
          backgroundColor: AppColors.success,
          icon: _getIconForType(ppeItem.type),
        );
      case PPEStatus.missing:
        return _PPEStatusConfig(
          backgroundColor: AppColors.error,
          icon: _getIconForType(ppeItem.type),
        );
      case PPEStatus.notSuitable:
        return _PPEStatusConfig(
          backgroundColor: AppColors.warning,
          icon: Icons.warning,
        );
      case PPEStatus.notRequired:
        return _PPEStatusConfig(
          backgroundColor: AppColors.textSecondary,
          icon: Icons.block,
        );
    }
  }

  IconData _getIconForType(PPEType type) {
    switch (type) {
      case PPEType.hardHat:
        return Icons.engineering;
      case PPEType.safetyGlasses:
        return Icons.visibility;
      case PPEType.vest:
        return Icons.checkroom;
      case PPEType.gloves:
        return Icons.back_hand;
      case PPEType.steelToedBoots:
        return Icons.work;
      case PPEType.earProtection:
        return Icons.hearing;
      case PPEType.hat:
        return Icons.engineering;
    }
  }

  String _getDefaultLabel() {
    switch (ppeItem.type) {
      case PPEType.hardHat:
        return 'Hard Hat';
      case PPEType.safetyGlasses:
        return 'Glasses';
      case PPEType.vest:
        return 'Vest';
      case PPEType.gloves:
        return 'Gloves';
      case PPEType.steelToedBoots:
        return 'Boots';
      case PPEType.earProtection:
        return 'Ear Protection';
      case PPEType.hat:
        return 'Hat';
    }
  }
}

@immutable
class _PPEStatusConfig {
  final Color backgroundColor;
  final IconData icon;

  const _PPEStatusConfig({required this.backgroundColor, required this.icon});
}

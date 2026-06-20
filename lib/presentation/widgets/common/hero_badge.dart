import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Large gradient icon badge used as the focal point of empty / intro states,
/// keeping the modern look consistent across upload and monitor screens.
@immutable
class HeroBadge extends StatelessWidget {
  final IconData icon;
  final double size;

  const HeroBadge({super.key, required this.icon, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF152444)],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 30,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.45, color: AppColors.accent),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/common/top_app_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;

/// Reusable "Coming Soon" placeholder screen for features under development.
@immutable
class ComingSoonScreen extends StatelessWidget {
  /// Icon to display for the feature
  final IconData icon;

  /// Feature name/title
  final String featureName;

  /// Optional description text
  final String? description;

  const ComingSoonScreen({
    super.key,
    required this.icon,
    required this.featureName,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(
        title: featureName,
        onBackPressed: () => Get.back(),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 50,
                  ),
                ),

                const SizedBox(height: 32),

                // Coming Soon text
                Text(
                  'Coming Soon',
                  style: styles.AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 16),

                // Feature name
                Text(
                  featureName,
                  style: styles.AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Optional description
                if (description != null) ...[
                  Text(
                    description!,
                    style: styles.AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 48),

                // Info message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This feature is currently under development and will be available in a future update.',
                          style: styles.AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

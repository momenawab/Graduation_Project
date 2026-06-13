import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart' as styles;

/// Home screen with SafeSight branding, function cards, and navigation.
@immutable
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar with profile icon
            _buildTopAppBar(controller),

            // Status banner
            _buildStatusBanner(controller),

            // Function cards grid
            Expanded(child: _buildFunctionCardsGrid(controller)),
          ],
        ),
      ),
    );
  }

  /// Builds the top app bar with profile icon.
  Widget _buildTopAppBar(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App branding
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: styles.AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    AppStrings.tagline,
                    style: styles.AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Profile icon button
          GestureDetector(
            onTap: controller.navigateToSettings,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the status banner showing system status.
  Widget _buildStatusBanner(HomeController controller) {
    return Obx(() {
      final statusColor = controller.getStatusColor();
      final statusIcon = controller.getStatusIcon();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.activeMonitoring,
                    style: styles.AppTextStyles.label.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppStrings.allSystemsNormal,
                    style: styles.AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Refresh button
            GestureDetector(
              onTap: controller.refreshSystemStatus,
              child: Icon(Icons.refresh, color: statusColor, size: 20),
            ),
          ],
        ),
      );
    });
  }

  /// Builds the 2x3 function cards grid.
  Widget _buildFunctionCardsGrid(HomeController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          // Monitoring card
          _FunctionCard(
            icon: Icons.videocam,
            title: 'Monitoring',
            subtitle: 'Real-time detection',
            color: AppColors.primary,
            onTap: controller.navigateToMonitoring,
          ),

          // Reports card
          _FunctionCard(
            icon: Icons.description,
            title: 'Reports',
            subtitle: 'Safety analytics',
            color: AppColors.primary,
            onTap: controller.navigateToReports,
          ),

          // Personnel card
          _FunctionCard(
            icon: Icons.people,
            title: 'Add Worker',
            subtitle: 'Worker management',
            color: AppColors.primary,
            onTap: controller.navigateToAddWorker,
          ),

          // Thresholds card
          _FunctionCard(
            icon: Icons.warning,
            title: 'Thresholds',
            subtitle: 'Alert settings',
            color: AppColors.warning,
            onTap: controller.navigateToAlertConfig,
          ),

          // Media card
          _FunctionCard(
            icon: Icons.cloud_upload,
            title: 'Media',
            subtitle: 'Upload images',
            color: AppColors.primary,
            onTap: controller.navigateToUploadDetection,
          ),

          // Workers Monitor card
          _FunctionCard(
            icon: Icons.person_search,
            title: 'Workers Monitor',
            subtitle: 'Scan & identify',
            color: AppColors.primary,
            onTap: controller.navigateToWorkerMonitor,
          ),
        ],
      ),
    );
  }
}

/// Function card widget for home screen grid.
@immutable
class _FunctionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FunctionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          // Title and subtitle
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

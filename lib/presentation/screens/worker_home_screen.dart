import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/worker_home_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/models/detection_result.dart';
import '../../data/models/notification.dart' as models;
import '../../routes/app_routes.dart';

/// Worker Home Screen - Dashboard for workers to view their compliance status.
@immutable
class WorkerHomeScreen extends StatelessWidget {
  const WorkerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkerHomeController controller = Get.put(WorkerHomeController());

    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.worker.value == null && controller.errorMessage.value.isEmpty) {
        controller.refresh();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.REPORT_INCIDENT),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.report_problem),
        label: const Text('Report Incident'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar
            _buildTopAppBar(controller),

            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading data',
                          style: styles.AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.errorMessage.value,
                          style: styles.AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.refresh,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Worker info card
                        _buildWorkerInfoCard(controller),
                        const SizedBox(height: 16),

                        // Compliance status card
                        _buildComplianceStatusCard(controller),
                        const SizedBox(height: 16),

                        // Quick actions
                        _buildQuickActions(controller),
                        const SizedBox(height: 16),

                        // Recent notifications
                        _buildRecentNotifications(controller),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top app bar
  Widget _buildTopAppBar(WorkerHomeController controller) {
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
                    'SafeSight Worker',
                    style: styles.AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                    ),
                  ),
                  Obx(() => Text(
                    controller.worker.value?.fullName ?? 'Loading...',
                    style: styles.AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  )),
                ],
              ),
            ],
          ),

          // Notification bell icon
          Obx(() => GestureDetector(
            onTap: controller.goToNotifications,
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondary,
                  ),
                  if (controller.unreadCount.value > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            controller.unreadCount.value > 9
                              ? '9+'
                              : '${controller.unreadCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  /// Builds the worker info card
  Widget _buildWorkerInfoCard(WorkerHomeController controller) {
    final worker = controller.worker.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Worker Information',
                style: styles.AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Worker ID', worker?.id ?? 'N/A'),
          _infoRow('Name', worker?.fullName ?? 'N/A'),
          _infoRow('Department', worker?.department ?? 'N/A'),
          _infoRow('Position', worker?.jobTitle ?? 'N/A'),
        ],
      ),
    );
  }

  /// Builds the compliance status card
  Widget _buildComplianceStatusCard(WorkerHomeController controller) {
    return Obx(() {
      final status = controller.todayStatus.value;
      final statusColor = _getStatusColor(status);
      final statusText = _getStatusText(status);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Compliance Status',
                  style: styles.AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: styles.AppTextStyles.headlineMedium.copyWith(
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _statChip(
                  'Violations Today',
                  '${controller.todayViolationCount.value}',
                  AppColors.error,
                ),
                const SizedBox(width: 8),
                _statChip(
                  'Total Violations',
                  '${controller.totalViolationCount.value}',
                  AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // F4 — personal compliance score + safe-day streak.
            Row(
              children: [
                _statChip(
                  'Compliance Score',
                  '${controller.complianceScore.value}%',
                  AppColors.success,
                ),
                const SizedBox(width: 8),
                _statChip(
                  'Days Since Violation',
                  '${controller.streakDays.value}',
                  AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Builds quick action buttons
  Widget _buildQuickActions(WorkerHomeController controller) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            icon: Icons.history,
            label: 'Violation History',
            color: AppColors.primary,
            onTap: controller.goToViolations,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionButton(
            icon: Icons.notifications,
            label: 'Notifications',
            color: AppColors.warning,
            onTap: controller.goToNotifications,
          ),
        ),
      ],
    );
  }

  /// Builds recent notifications section
  Widget _buildRecentNotifications(WorkerHomeController controller) {
    return Obx(() {
      final recentNotifications = controller.notifications.take(3).toList();

      if (recentNotifications.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Recent Notifications',
                  style: styles.AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'You\'re doing great!',
                  style: styles.AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Recent Notifications',
              style: styles.AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...recentNotifications.map((notification) => _notificationTile(notification)),
        ],
      );
    });
  }

  /// Builds a notification tile
  Widget _notificationTile(models.Notification notification) {
    final isHighSeverity = notification.severity == models.NotificationSeverity.high;
    final color = isHighSeverity ? AppColors.error : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.read
            ? Colors.transparent
            : color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isHighSeverity ? Icons.warning : Icons.info_outline,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: styles.AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.body,
                  style: styles.AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(notification.timestamp),
            style: styles.AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Info row widget
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: styles.AppTextStyles.bodyMedium,
          ),
          Text(
            value,
            style: styles.AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Stat chip widget
  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: styles.AppTextStyles.bodySmall,
          ),
          Text(
            value,
            style: styles.AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Action button widget
  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: styles.AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return AppColors.success;
      case ComplianceStatus.partial:
        return AppColors.warning;
      case ComplianceStatus.nonCompliant:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get status text
  String _getStatusText(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return 'Fully Compliant';
      case ComplianceStatus.partial:
        return 'Partial Compliance';
      case ComplianceStatus.nonCompliant:
        return 'Non-Compliant';
      default:
        return 'Unknown';
    }
  }

  /// Get status icon
  IconData _getStatusIcon(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return Icons.check_circle;
      case ComplianceStatus.partial:
        return Icons.warning;
      case ComplianceStatus.nonCompliant:
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  /// Format timestamp
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/worker_home_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/models/notification.dart' as models;

/// Worker Notifications Screen - Shows all notifications for the worker.
@immutable
class WorkerNotificationsScreen extends StatelessWidget {
  const WorkerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkerHomeController controller = Get.find<WorkerHomeController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: styles.AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.unreadCount.value > 0
              ? controller.notifications.clear
              : null,
            child: Text(
              'Clear All',
              style: styles.AppTextStyles.bodyMedium.copyWith(
                color: controller.unreadCount.value > 0
                  ? AppColors.primary
                  : AppColors.textDisabled,
              ),
            ),
          )),
        ],
      ),
      body: Obx(() {
        final notifications = controller.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_outlined,
                  size: 64,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Notifications',
                  style: styles.AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up!',
                  style: styles.AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _notificationTile(notification, controller);
          },
        );
      }),
    );
  }

  /// Builds a notification tile
  Widget _notificationTile(models.Notification notification, WorkerHomeController controller) {
    final isHighSeverity = notification.severity == models.NotificationSeverity.high;
    final color = isHighSeverity ? AppColors.error : AppColors.warning;
    final isRead = notification.read;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? AppColors.cardBackground.withValues(alpha: 0.5) : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.transparent : color.withValues(alpha: 0.3),
          width: isRead ? 0 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Severity indicator
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

              // Title and timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: styles.AppTextStyles.bodyLarge.copyWith(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatFullTime(notification.timestamp),
                      style: styles.AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Body text
          Text(
            notification.body,
            style: styles.AppTextStyles.bodyMedium,
          ),

          // Missing PPE details if violation
          if (notification.type == models.NotificationType.violation &&
              notification.missingPpe.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Missing PPE:',
                    style: styles.AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: notification.missingPpe.map((ppe) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatPPEName(ppe),
                          style: styles.AppTextStyles.bodySmall.copyWith(
                            color: color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Format full timestamp
  String _formatFullTime(DateTime timestamp) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? "s" : ""} ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours > 1 ? "s" : ""} ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday at ${_formatHour(timestamp)}';
    } else if (diff.inDays < 7) {
      return '${months[timestamp.month - 1]} ${timestamp.day} at ${_formatHour(timestamp)}';
    } else {
      return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
    }
  }

  /// Format hour
  String _formatHour(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Format PPE name for display
  String _formatPPEName(String ppe) {
    return ppe
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/worker_violations_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;

/// Worker Violations Screen - Shows worker's personal violation history.
@immutable
class WorkerViolationsScreen extends StatelessWidget {
  const WorkerViolationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkerViolationsController controller = Get.put(WorkerViolationsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: controller.goBack,
        ),
        title: Text(
          'My Violations',
          style: styles.AppTextStyles.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.filteredViolations.isEmpty ? null : controller.refresh,
            child: Row(
              children: [
                const Icon(Icons.refresh, color: AppColors.primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Refresh',
                  style: styles.AppTextStyles.bodyMedium.copyWith(
                    color: controller.filteredViolations.isEmpty
                        ? AppColors.textDisabled
                        : AppColors.primary,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
      body: Obx(() {
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
                  'Error loading violations',
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

        final violations = controller.filteredViolations;

        if (violations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.success,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Violations Found',
                  style: styles.AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptyMessage(controller.selectedFilter.value),
                  style: styles.AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Filter chips
            _buildFilterChips(controller),
            // Violations list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: violations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _violationCard(violations[index], index);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Build filter chips
  Widget _buildFilterChips(WorkerViolationsController controller) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 8,
          children: [
            _filterChip('All', 'all', controller.selectedFilter.value, controller),
            _filterChip('Today', 'today', controller.selectedFilter.value, controller),
            _filterChip('This Week', 'week', controller.selectedFilter.value, controller),
            _filterChip('This Month', 'month', controller.selectedFilter.value, controller),
          ],
        ),
      );
    });
  }

  /// Filter chip widget
  Widget _filterChip(
    String label,
    String value,
    String selectedValue,
    WorkerViolationsController controller,
  ) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () => controller.setFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: styles.AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// Violation card widget
  Widget _violationCard(Map<String, dynamic> violation, int index) {
    final timestamp = DateTime.tryParse(violation['timestamp']?.toString() ?? '') ?? DateTime.now();
    final severity = violation['severity'] as String? ?? 'medium';
    final missingPpe = violation['missing_ppe'] as List? ?? [];
    final status = violation['status'] as String? ?? 'open';

    final severityColor = _getSeverityColor(severity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with timestamp and severity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${violation['violation_id']?.toString().substring(0, 8) ?? 'N/A'}',
                      style: styles.AppTextStyles.bodySmall.copyWith(
                        color: severityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(timestamp),
                    style: styles.AppTextStyles.bodySmall,
                  ),
                ],
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 12),

          // Missing PPE
          if (missingPpe.isNotEmpty) ...[
            Text(
              'Missing PPE:',
              style: styles.AppTextStyles.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: missingPpe.map((ppe) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _formatPPEName(ppe.toString()),
                    style: styles.AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // F4 — acknowledge action.
          const SizedBox(height: 12),
          if (violation['acknowledged_at'] != null)
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                Text('Acknowledged',
                    style: styles.AppTextStyles.bodySmall
                        .copyWith(color: AppColors.success)),
              ],
            )
          else
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.done, size: 16),
                label: const Text('Acknowledge'),
                onPressed: () => Get.find<WorkerViolationsController>()
                    .acknowledge(violation['violation_id']?.toString() ?? ''),
              ),
            ),
        ],
      ),
    );
  }

  /// Status badge widget
  Widget _statusBadge(String status) {
    final (label, color) = switch (status) {
      'open' => ('Open', AppColors.error),
      'reviewed' => ('Reviewed', AppColors.warning),
      'resolved' => ('Resolved', AppColors.success),
      'dismissed' => ('Dismissed', AppColors.textSecondary),
      _ => (status, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: styles.AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Get severity color
  Color _getSeverityColor(String severity) {
    return switch (severity.toLowerCase()) {
      'low' => AppColors.warning,
      'medium' => AppColors.warning,
      'high' => AppColors.error,
      'critical' => AppColors.critical,
      _ => AppColors.textSecondary,
    };
  }

  /// Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 24) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Format PPE name for display
  String _formatPPEName(String ppe) {
    return ppe
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Get empty message based on filter
  String _getEmptyMessage(String filter) {
    return switch (filter) {
      'today' => 'No violations recorded today. Keep up the good work!',
      'week' => 'No violations recorded this week.',
      'month' => 'No violations recorded this month.',
      _ => 'No violations found. You\'re doing great!',
    };
  }
}

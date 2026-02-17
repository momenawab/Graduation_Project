import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/worker_details_controller.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;
import 'package:intl/intl.dart';

/// Worker Details screen showing worker info and violation history.
@immutable
class WorkerDetailsScreen extends StatelessWidget {
  final String workerId;

  const WorkerDetailsScreen({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    final WorkerDetailsController controller = Get.put(
      WorkerDetailsController(workerId: workerId),
      tag: workerId,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar
            _buildTopAppBar(),

            // Content area
            Expanded(child: _buildContent(controller)),

            // Bottom navigation
            const BottomNavBar(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  /// Builds top app bar with back button.
  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Worker Details',
            style: styles.AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds main content area.
  Widget _buildContent(WorkerDetailsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorState(controller);
      }

      if (controller.workerData.value == null) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worker info card
              _buildWorkerInfoCard(controller),

              const SizedBox(height: 16),

              // Compliance rate card
              _buildComplianceCard(controller),

              const SizedBox(height: 16),

              // Violations history section
              _buildViolationsSection(controller),
            ],
          ),
        ),
      );
    });
  }

  /// Builds worker info card.
  Widget _buildWorkerInfoCard(WorkerDetailsController controller) {
    final worker = controller.workerData.value!;
    final name = worker['name'] as String? ?? 'Unknown';
    final workerId = worker['worker_id'] as String? ?? '';
    final department = worker['department'] as String? ?? '';
    final position = worker['position'] as String? ?? '';

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 40,
            ),
          ),

          const SizedBox(height: 16),

          // Name
          Text(
            name,
            style: styles.AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          // Worker ID
          Text(
            'ID: $workerId',
            style: styles.AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Info rows
          _InfoRow(
            icon: Icons.business,
            label: 'Department',
            value: department,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.work,
            label: 'Position',
            value: position,
          ),
        ],
      ),
    );
  }

  /// Builds compliance rate card.
  Widget _buildComplianceCard(WorkerDetailsController controller) {
    final rate = controller.complianceRate;
    final level = controller.complianceLevel;
    final colorKey = controller.complianceColor;

    Color getColor() {
      switch (colorKey) {
        case 'success':
          return AppColors.success;
        case 'warning':
          return AppColors.warning;
        case 'error':
          return AppColors.error;
        default:
          return AppColors.primary;
      }
    }

    final color = getColor();

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Compliance Rate',
                style: styles.AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rate display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${rate.toStringAsFixed(1)}%',
                    style: styles.AppTextStyles.headlineLarge.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                    ),
                  ),
                  Text(
                    level,
                    style: styles.AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          value: rate / 100,
                          color: color,
                          backgroundColor: AppColors.cardBackground,
                          strokeWidth: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: rate / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds violations section.
  Widget _buildViolationsSection(WorkerDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Violation History',
              style: styles.AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => Text(
              '(${controller.violations.length})',
              style: styles.AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )),
          ],
        ),

        const SizedBox(height: 12),

        Obx(() {
          if (controller.violations.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No Violations',
                    style: styles.AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This worker has a clean record',
                    style: styles.AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: controller.violations.map((violation) {
              return _ViolationCard(violation: violation);
            }).toList(),
          );
        }),
      ],
    );
  }

  /// Builds loading state.
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primary,
      ),
    );
  }

  /// Builds error state.
  Widget _buildErrorState(WorkerDetailsController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: styles.AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds empty state.
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Worker not found',
        style: styles.AppTextStyles.bodyLarge,
      ),
    );
  }
}

/// Info row widget for worker details.
@immutable
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: styles.AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: styles.AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Violation card widget.
@immutable
class _ViolationCard extends StatelessWidget {
  final Map<String, dynamic> violation;

  const _ViolationCard({required this.violation});

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getSeverity(String? severity) {
    return severity?.toLowerCase() == 'high' ? 'High' : 'Low';
  }

  Color _getSeverityColor(String? severity) {
    if (severity?.toLowerCase() == 'high') {
      return AppColors.error;
    }
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final severity = violation['severity'] as String?;
    final severityColor = _getSeverityColor(severity);
    final timestamp = violation['timestamp'] as String? ?? '';
    final missingPpe = violation['missing_ppe'] as List<dynamic>? ?? [];

    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.error,
                    color: severityColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getSeverity(severity) + ' Severity',
                    style: styles.AppTextStyles.bodyMedium.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                _formatDate(timestamp),
                style: styles.AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          if (missingPpe.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Missing PPE:',
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: missingPpe.map((ppe) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ppe.toString(),
                    style: styles.AppTextStyles.bodySmall.copyWith(
                      color: severityColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../widgets/common/status_badge.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/models/report_data.dart';
import '../../routes/app_routes.dart';

/// Reports screen with safety analytics, metrics, and chart visualization.
@immutable
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportsController controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top app bar with filter icon
            _buildTopAppBar(controller),

            // Content area
            Expanded(child: _buildContent(controller)),

            // Bottom navigation
            const BottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  /// Builds top app bar with title and filter icon.
  Widget _buildTopAppBar(ReportsController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button and title
          Row(
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
                AppStrings.reports,
                style: styles.AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          // Filter icon button
          GestureDetector(
            onTap: controller.openFilterDialog,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.filter_list,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds main content area.
  Widget _buildContent(ReportsController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Summary cards row
          _buildSummaryCards(controller),

          const SizedBox(height: 16),

          // Live updates toggle
          _buildLiveUpdatesToggle(controller),

          const SizedBox(height: 16),

          // Chart card
          _buildChartCard(controller),

          const SizedBox(height: 16),

          // Sync banner
          _buildSyncBanner(),

          const SizedBox(height: 16),

          // Worker violations list
          _buildWorkerViolationsSection(controller),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds summary cards row (Incidents and Compliance).
  Widget _buildSummaryCards(ReportsController controller) {
    return Obx(() {
      final reportData = controller.reportData.value;
      if (reportData == null) {
        return const SizedBox.shrink();
      }

      return Row(
        children: [
          // Incidents card
          Expanded(
            child: _SummaryCard(
              icon: Icons.warning,
              title: AppStrings.incidents,
              value: reportData.incidents.toString(),
              trend: reportData.incidentsTrend,
              valueColor: AppColors.error,
              trendColor: controller.getTrendColor(reportData.incidentsTrend),
              trendIcon: controller.getTrendIcon(reportData.incidentsTrend),
              formattedTrend: controller.getFormattedTrend(
                reportData.incidentsTrend,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Compliance card
          Expanded(
            child: _SummaryCard(
              icon: Icons.shield,
              title: AppStrings.compliance,
              value: '${reportData.compliance}%',
              trend: reportData.complianceTrend,
              valueColor: AppColors.primary,
              trendColor: controller.getTrendColor(reportData.complianceTrend),
              trendIcon: controller.getTrendIcon(reportData.complianceTrend),
              formattedTrend: controller.getFormattedTrend(
                reportData.complianceTrend,
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Builds live updates toggle switch.
  Widget _buildLiveUpdatesToggle(ReportsController controller) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  controller.liveUpdates.value
                      ? Icons.sync
                      : Icons.sync_disabled,
                  color: controller.liveUpdates.value
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.liveUpdates,
                  style: styles.AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            // Toggle switch
            GestureDetector(
              onTap: controller.toggleLiveUpdates,
              child: Container(
                width: 52,
                height: 28,
                decoration: BoxDecoration(
                  color: controller.liveUpdates.value
                      ? AppColors.primary
                      : AppColors.textDisabled,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Align(
                    alignment: controller.liveUpdates.value
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Builds chart card with placeholder for bar chart.
  Widget _buildChartCard(ReportsController controller) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.safetyInsightEngine,
                  style: styles.AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart placeholder (bar chart visualization)
          Obx(() {
            final reportData = controller.reportData.value;
            if (reportData == null) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 200,
              child: _BarChartPlaceholder(data: reportData.chartData),
            );
          }),
        ],
      ),
    );
  }

  /// Builds sync banner with AI detection message.
  Widget _buildSyncBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_sync, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.aiDetectionActive,
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds worker violations list section.
  Widget _buildWorkerViolationsSection(ReportsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.people, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Worker Violations',
              style: styles.AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Obx(() {
          final workers = controller.workerStats;

          if (workers.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: AppColors.textSecondary,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No worker data available',
                      style: styles.AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: workers.map((worker) {
              return _WorkerViolationCard(
                workerId: worker.workerId,
                name: worker.name,
                photoUrl: worker.photoUrl,
                violationCount: worker.violationCount,
                complianceRate: worker.complianceRate,
                onTap: () => Get.toNamed(
                  '${AppRoutes.WORKER_DETAILS.replaceAll(':id', worker.workerId)}',
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

/// Summary card widget for reports screen.
@immutable
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final double trend;
  final Color valueColor;
  final Color trendColor;
  final IconData trendIcon;
  final String formattedTrend;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.trend,
    required this.valueColor,
    required this.trendColor,
    required this.trendIcon,
    required this.formattedTrend,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and title
          Row(
            children: [
              Icon(icon, color: valueColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: styles.AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Value
          Text(
            value,
            style: styles.AppTextStyles.headlineLarge.copyWith(
              color: valueColor,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 4),

          // Trend
          Row(
            children: [
              Icon(trendIcon, color: trendColor, size: 16),
              const SizedBox(width: 4),
              Text(
                formattedTrend,
                style: styles.AppTextStyles.bodySmall.copyWith(
                  color: trendColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bar chart placeholder widget.
@immutable
class _BarChartPlaceholder extends StatelessWidget {
  final List<ChartDataPoint> data;

  const _BarChartPlaceholder({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((point) {
        final barHeight = (point.value / maxValue) * 160;
        return Column(
          children: [
            Container(
              width: 32,
              height: barHeight,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              point.label,
              style: styles.AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

/// Reports bottom navigation widget.
@immutable
class _ReportsBottomNav extends StatelessWidget {
  final int currentIndex;

  const _ReportsBottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(
          top: BorderSide(color: AppColors.textSecondary, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.live_tv,
            label: 'Live',
            isActive: currentIndex == 0,
            onTap: () => Get.toNamed('/monitoring'),
          ),
          _NavItem(
            icon: Icons.description,
            label: 'Log',
            isActive: currentIndex == 1,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.people,
            label: 'Team',
            isActive: currentIndex == 2,
            onTap: () => Get.toNamed('/worker/add'),
          ),
          _NavItem(
            icon: Icons.insert_chart,
            label: 'Reports',
            isActive: currentIndex == 3,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Navigation item widget for bottom nav.
@immutable
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: styles.AppTextStyles.bodySmall.copyWith(
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Worker violation card widget for reports screen.
@immutable
class _WorkerViolationCard extends StatelessWidget {
  final String workerId;
  final String name;
  final String? photoUrl;
  final int violationCount;
  final double complianceRate;
  final VoidCallback onTap;

  const _WorkerViolationCard({
    required this.workerId,
    required this.name,
    this.photoUrl,
    required this.violationCount,
    required this.complianceRate,
    required this.onTap,
  });

  Color _getComplianceColor() {
    if (complianceRate >= 95) return AppColors.success;
    if (complianceRate >= 85) return AppColors.primary;
    if (complianceRate >= 70) return AppColors.warning;
    return AppColors.error;
  }

  String _getComplianceLevel() {
    if (complianceRate >= 95) return 'Excellent';
    if (complianceRate >= 85) return 'Good';
    if (complianceRate >= 70) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final complianceColor = _getComplianceColor();

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Worker photo or placeholder
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: photoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                        size: 28,
                      ),
              ),

              const SizedBox(width: 12),

              // Worker info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: styles.AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.shield, color: complianceColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${complianceRate.toStringAsFixed(0)}% ${_getComplianceLevel()}',
                          style: styles.AppTextStyles.bodySmall.copyWith(
                            color: complianceColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Violation count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: violationCount > 0
                      ? AppColors.error.withValues(alpha: 0.15)
                      : AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: violationCount > 0
                        ? AppColors.error.withValues(alpha: 0.5)
                        : AppColors.success.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$violationCount',
                      style: styles.AppTextStyles.bodyLarge.copyWith(
                        color: violationCount > 0
                            ? AppColors.error
                            : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Violations',
                      style: styles.AppTextStyles.bodySmall.copyWith(
                        color: violationCount > 0
                            ? AppColors.error
                            : AppColors.success,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

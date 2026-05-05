import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../routes/app_routes.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(controller),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.loadReportData();
                  await controller.loadWorkerStats();
                },
                color: AppColors.primary,
                backgroundColor: AppColors.cardBackground,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SummaryCards(controller: controller),
                      const SizedBox(height: 16),
                      _LiveToggle(controller: controller),
                      const SizedBox(height: 16),
                      _ComplianceTrendChart(controller: controller),
                      const SizedBox(height: 16),
                      _ViolationsBarChart(controller: controller),
                      const SizedBox(height: 16),
                      _DepartmentPieChart(controller: controller),
                      const SizedBox(height: 16),
                      _WorkerViolationsList(controller: controller),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            const BottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ReportsController controller) {
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
              child: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppStrings.reports,
              style: styles.AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.textPrimary, fontSize: 20),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await controller.loadReportData();
              await controller.loadWorkerStats();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.refresh,
                  color: AppColors.textPrimary, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary Cards ────────────────────────────────────────────────────────────

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final report = controller.reportData.value;
      final total = controller.totalWorkers.value;
      final active = controller.activeWorkers.value;

      return Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.warning_amber_rounded,
              label: 'Violations',
              value: report?.incidents.toString() ?? '—',
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.shield_outlined,
              label: 'Compliance',
              value: report != null ? '${report.compliance}%' : '—',
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              icon: Icons.people_outline,
              label: 'Workers',
              value: total > 0 ? '$active / $total' : '—',
              color: AppColors.success,
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: styles.AppTextStyles.headlineLarge.copyWith(
                  color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              style: styles.AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Live Toggle ──────────────────────────────────────────────────────────────

class _LiveToggle extends StatelessWidget {
  const _LiveToggle({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                controller.liveUpdates.value ? Icons.sync : Icons.sync_disabled,
                color: controller.liveUpdates.value
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(AppStrings.liveUpdates,
                    style: styles.AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.textPrimary)),
              ),
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
                            color: Colors.white, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// ── Compliance Trend Line Chart ───────────────────────────────────────────────

class _ComplianceTrendChart extends StatelessWidget {
  const _ComplianceTrendChart({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.reportData.value?.chartData ?? [];

      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChartTitle(
                icon: Icons.show_chart,
                title: 'Compliance Trend (7 days)',
                color: AppColors.primary),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: data.isEmpty
                  ? _EmptyChart(message: 'No trend data yet')
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: AppColors.textDisabled.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              getTitlesWidget: (v, _) => Text(
                                '${v.toInt()}%',
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final i = v.toInt();
                                if (i < 0 || i >= data.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(data[i].label,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10)),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        maxY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            spots: data.asMap().entries.map((e) {
                              return FlSpot(
                                  e.key.toDouble(), e.value.value);
                            }).toList(),
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 2.5,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                radius: 4,
                                color: AppColors.primary,
                                strokeWidth: 2,
                                strokeColor: AppColors.background,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color:
                                  AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Top Violations Bar Chart ──────────────────────────────────────────────────

class _ViolationsBarChart extends StatelessWidget {
  const _ViolationsBarChart({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final workers = controller.workerStats
          .where((w) => w.violationCount > 0)
          .toList()
        ..sort((a, b) => b.violationCount.compareTo(a.violationCount));
      final top = workers.take(5).toList();

      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChartTitle(
                icon: Icons.bar_chart,
                title: 'Top Violations by Worker',
                color: AppColors.error),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: top.isEmpty
                  ? _EmptyChart(message: 'No violations recorded')
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final name = top[group.x].name.split(' ').first;
                              return BarTooltipItem(
                                '$name\n${rod.toY.toInt()} violations',
                                const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              getTitlesWidget: (v, _) => Text(
                                v.toInt().toString(),
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final i = v.toInt();
                                if (i < 0 || i >= top.length) {
                                  return const SizedBox.shrink();
                                }
                                final name =
                                    top[i].name.split(' ').first;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(name,
                                      style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 10)),
                                );
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: AppColors.textDisabled.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: top.asMap().entries.map((e) {
                          return BarChartGroupData(x: e.key, barRods: [
                            BarChartRodData(
                              toY: e.value.violationCount.toDouble(),
                              color: AppColors.error,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Department Pie Chart ──────────────────────────────────────────────────────

class _DepartmentPieChart extends StatelessWidget {
  const _DepartmentPieChart({required this.controller});
  final ReportsController controller;

  static const _colors = [
    AppColors.primary,
    AppColors.error,
    AppColors.success,
    AppColors.warning,
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final depts = controller.departmentStats;

      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChartTitle(
                icon: Icons.pie_chart_outline,
                title: 'Workers by Department',
                color: AppColors.success),
            const SizedBox(height: 16),
            depts.isEmpty
                ? _EmptyChart(message: 'No department data')
                : Row(
                    children: [
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: depts.asMap().entries.map((e) {
                              final color =
                                  _colors[e.key % _colors.length];
                              final count =
                                  e.value['count'] as int? ?? 0;
                              return PieChartSectionData(
                                color: color,
                                value: count.toDouble(),
                                title: '$count',
                                radius: 50,
                                titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: depts.asMap().entries.map((e) {
                            final color = _colors[e.key % _colors.length];
                            final dept = e.value['department'] as String? ??
                                'Unknown';
                            final count = e.value['count'] as int? ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      dept,
                                      style: styles.AppTextStyles.bodySmall
                                          .copyWith(
                                              color:
                                                  AppColors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '$count',
                                    style: styles.AppTextStyles.bodySmall
                                        .copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      );
    });
  }
}

// ── Worker Violations List ────────────────────────────────────────────────────

class _WorkerViolationsList extends StatelessWidget {
  const _WorkerViolationsList({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final workers = controller.workerStats;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Worker Violations',
                  style: styles.AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          if (workers.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.people_outline,
                        color: AppColors.textSecondary, size: 40),
                    const SizedBox(height: 12),
                    Text('No worker data available',
                        style: styles.AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            ...workers.map((w) => _WorkerCard(worker: w)),
        ],
      );
    });
  }
}

class _WorkerCard extends StatelessWidget {
  const _WorkerCard({required this.worker});
  final WorkerViolationStats worker;

  Color get _complianceColor {
    final r = worker.complianceRate;
    if (r >= 95) return AppColors.success;
    if (r >= 85) return AppColors.primary;
    if (r >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
          AppRoutes.WORKER_DETAILS.replaceAll(':id', worker.workerId)),
      child: AppCard(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.name,
                        style: styles.AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.shield,
                            color: _complianceColor, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          '${worker.complianceRate.toStringAsFixed(0)}% compliance',
                          style: styles.AppTextStyles.bodySmall
                              .copyWith(color: _complianceColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: worker.violationCount > 0
                      ? AppColors.error.withValues(alpha: 0.15)
                      : AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: worker.violationCount > 0
                        ? AppColors.error.withValues(alpha: 0.5)
                        : AppColors.success.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Text('${worker.violationCount}',
                        style: styles.AppTextStyles.bodyLarge.copyWith(
                            color: worker.violationCount > 0
                                ? AppColors.error
                                : AppColors.success,
                            fontWeight: FontWeight.w700)),
                    Text('violations',
                        style: styles.AppTextStyles.bodySmall.copyWith(
                            color: worker.violationCount > 0
                                ? AppColors.error
                                : AppColors.success,
                            fontSize: 9)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _ChartTitle extends StatelessWidget {
  const _ChartTitle(
      {required this.icon, required this.title, required this.color});
  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: styles.AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bar_chart_outlined,
              color: AppColors.textSecondary, size: 40),
          const SizedBox(height: 8),
          Text(message,
              style: styles.AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../widgets/common/bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

// ── Colour palette matching the Power BI dark theme ──────────────────────────
const _bgColor = Color(0xFF0E1117);
const _cardColor = Color(0xFF1A1F2E);
const _borderBlue = Color(0xFF3B82F6);
const _borderYellow = Color(0xFFF59E0B);
const _borderGreen = Color(0xFF10B981);
const _borderRed = Color(0xFFEF4444);
const _textPrimary = Color(0xFFE2E8F0);
const _textSecondary = Color(0xFF8892A4);
const _chartBlue = Color(0xFF60A5FA);

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: _bgColor,
      drawer: _FilterDrawer(controller: c),
      body: SafeArea(
        child: Column(
          children: [
            _Header(controller: c),
            Expanded(
              child: Obx(() {
                if (c.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: _borderBlue));
                }
                return RefreshIndicator(
                  onRefresh: c.loadAll,
                  color: _borderBlue,
                  backgroundColor: _cardColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _KpiRow(controller: c),
                        const SizedBox(height: 12),
                        _TimelineCard(controller: c),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                flex: 55,
                                child: _HorizontalBarCard(controller: c)),
                            const SizedBox(width: 12),
                            Expanded(
                                flex: 45,
                                child: _PieCard(controller: c)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _WorkerList(controller: c),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const BottomNavBar(currentIndex: 2),
          ],
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: const BoxDecoration(
        color: _cardColor,
        border: Border(bottom: BorderSide(color: Color(0xFF2D3748), width: 1)),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: const Icon(Icons.tune, color: _textSecondary, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Safety & Compliance Dashboard',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'All Sites  |  Last 90 days',
                  style: TextStyle(
                      color: _textSecondary.withValues(alpha: 0.8),
                      fontSize: 11),
                ),
              ],
            ),
          ),
          // LIVE badge
          Obx(() => GestureDetector(
                onTap: controller.toggleLiveUpdates,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: controller.liveUpdates.value
                        ? _borderYellow
                        : _cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderYellow, width: 1.5),
                  ),
                  child: Text(
                    'live',
                    style: TextStyle(
                      color: controller.liveUpdates.value
                          ? Colors.black
                          : _borderYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.close, color: _textSecondary, size: 22),
          ),
        ],
      ),
    );
  }
}

// ── Filter Drawer ─────────────────────────────────────────────────────────────

class _FilterDrawer extends StatelessWidget {
  const _FilterDrawer({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _cardColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final depts = controller.departments;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filters',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                const Text('Department',
                    style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...depts.map((d) => _FilterItem(
                      label: d,
                      selected: controller.selectedDept.value == d,
                      onTap: () {
                        controller.selectedDept.value = d;
                        Navigator.pop(context);
                      },
                    )),
                const SizedBox(height: 20),
                const Text('Risk Category',
                    style: TextStyle(
                        color: _textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...['All', 'High Risk', 'Moderate Risk', 'Safe'].map((r) =>
                    _FilterItem(
                      label: r,
                      selected: controller.selectedRisk.value == r,
                      onTap: () {
                        controller.selectedRisk.value = r;
                        Navigator.pop(context);
                      },
                    )),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  const _FilterItem(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(color: _borderBlue, width: 1.5),
                borderRadius: BorderRadius.circular(3),
                color: selected ? _borderBlue : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 11)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(color: _textPrimary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

// ── KPI Cards ─────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
                child: _KpiCard(
                    label: 'Total_Workers',
                    value: _fmt(controller.totalWorkers.value),
                    borderColor: _borderBlue)),
            const SizedBox(width: 8),
            Expanded(
                child: _KpiCard(
                    label: 'Total_Violations',
                    value: _fmt(controller.totalViolations.value),
                    borderColor: _borderYellow)),
            const SizedBox(width: 8),
            Expanded(
                child: _KpiCard(
                    label: 'Compliance_Rate',
                    value: controller.complianceRate.value.toStringAsFixed(2),
                    borderColor: _borderGreen)),
            const SizedBox(width: 8),
            Expanded(
                child: _KpiCard(
                    label: 'High_Risk_%',
                    value: controller.highRiskPercent.value.toStringAsFixed(2),
                    borderColor: _borderRed)),
          ],
        ));
  }

  String _fmt(int v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}K' : '$v';
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.borderColor});
  final String label;
  final String value;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: _textSecondary, fontSize: 10),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Timeline Line Chart ───────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Total_Violations by Year, Month and Day',
      child: Obx(() {
        final data = controller.dailyViolations;
        if (data.isEmpty) {
          return const _EmptyChart(message: 'No violation data yet');
        }
        final maxY = data
                .map((d) => d.count.toDouble())
                .reduce((a, b) => a > b ? a : b) +
            1;

        return SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (_) => FlLine(
                    color: const Color(0xFF2D3748), strokeWidth: 0.5),
                getDrawingVerticalLine: (_) =>
                    FlLine(
                        color: const Color(0xFF2D3748),
                        strokeWidth: 0.5,
                        dashArray: [4, 4]),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: const RotatedBox(
                    quarterTurns: 3,
                    child: Text('Total_Violations',
                        style: TextStyle(
                            color: _textSecondary, fontSize: 9)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 9),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Year',
                      style:
                          TextStyle(color: _textSecondary, fontSize: 9)),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (data.length / 5).ceilToDouble(),
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= data.length) {
                        return const SizedBox.shrink();
                      }
                      final d = data[i].date;
                      final months = [
                        'Jan','Feb','Mar','Apr','May','Jun',
                        'Jul','Aug','Sep','Oct','Nov','Dec'
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${months[d.month - 1]} ${d.year}',
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 9),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border:
                    Border.all(color: const Color(0xFF2D3748), width: 0.5),
              ),
              minY: 0,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: data.asMap().entries
                      .map((e) =>
                          FlSpot(e.key.toDouble(), e.value.count.toDouble()))
                      .toList(),
                  isCurved: false,
                  color: _chartBlue,
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: _chartBlue.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Horizontal Bar Chart ──────────────────────────────────────────────────────

class _HorizontalBarCard extends StatelessWidget {
  const _HorizontalBarCard({required this.controller});
  final ReportsController controller;

  static const _barColors = [
    _borderBlue, _borderBlue, _borderYellow, _borderBlue, _borderRed,
  ];

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Total_Violations by Site',
      child: Obx(() {
        final data = controller.violationsByDept;
        if (data.isEmpty) {
          return const _EmptyChart(message: 'No site data');
        }
        return SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.center,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${data[group.x].department}\n${rod.toY.toInt()}',
                      const TextStyle(color: Colors.white, fontSize: 11),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: const RotatedBox(
                    quarterTurns: 3,
                    child: Text('Site',
                        style: TextStyle(
                            color: _textSecondary, fontSize: 9)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 72,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= data.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          data[i].department,
                          style: const TextStyle(
                              color: _textSecondary, fontSize: 9),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Total_Violations',
                      style:
                          TextStyle(color: _textSecondary, fontSize: 9)),
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 9),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: false,
                getDrawingVerticalLine: (_) =>
                    FlLine(color: const Color(0xFF2D3748), strokeWidth: 0.5),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                    color: const Color(0xFF2D3748), width: 0.5),
              ),
              barGroups: data.asMap().entries.map((e) {
                final color = _barColors[e.key % _barColors.length];
                return BarChartGroupData(
                  x: e.key,
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.count.toDouble(),
                      color: color,
                      width: 14,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(3)),
                    ),
                  ],
                );
              }).toList(),
              groupsSpace: 10,
            ),
            duration: Duration.zero,
          ),
        );
      }),
    );
  }
}

// ── Pie Chart ─────────────────────────────────────────────────────────────────

class _PieCard extends StatelessWidget {
  const _PieCard({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return _DashCard(
      title: 'Count of Worker_ID by Violation',
      child: Obx(() {
        final violated = controller.violatedWorkers.value;
        final compliant = controller.compliantWorkers.value;
        final total = violated + compliant;
        if (total == 0) {
          return const _EmptyChart(message: 'No worker data');
        }
        final yesPercent = (violated / total * 100);
        final noPercent = (compliant / total * 100);

        return Column(
          children: [
            SizedBox(
              height: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  startDegreeOffset: -90,
                  sections: [
                    PieChartSectionData(
                      color: _borderRed,
                      value: violated.toDouble(),
                      title:
                          '$violated (${yesPercent.toStringAsFixed(1)}%)',
                      radius: 70,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600),
                      titlePositionPercentageOffset: 0.65,
                    ),
                    PieChartSectionData(
                      color: _borderGreen,
                      value: compliant.toDouble(),
                      title:
                          '$compliant (${noPercent.toStringAsFixed(1)}%)',
                      radius: 70,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600),
                      titlePositionPercentageOffset: 0.65,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: _borderRed, label: 'Yes'),
                const SizedBox(width: 16),
                _Legend(color: _borderGreen, label: 'No'),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style:
                const TextStyle(color: _textSecondary, fontSize: 11)),
      ],
    );
  }
}

// ── Worker List ───────────────────────────────────────────────────────────────

class _WorkerList extends StatelessWidget {
  const _WorkerList({required this.controller});
  final ReportsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final workers = controller.workerStats;
      if (workers.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Workers',
              style: TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...workers.map((w) => _WorkerRow(worker: w)),
        ],
      );
    });
  }
}

class _WorkerRow extends StatelessWidget {
  const _WorkerRow({required this.worker});
  final WorkerViolationStats worker;

  @override
  Widget build(BuildContext context) {
    final hasViolation = worker.violationCount > 0;
    return GestureDetector(
      onTap: () => Get.toNamed(
          AppRoutes.WORKER_DETAILS.replaceAll(':id', worker.workerId)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF2D3748), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _borderBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.person, color: _borderBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.name,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  Text(worker.workerId,
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (hasViolation ? _borderRed : _borderGreen)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                    color: (hasViolation ? _borderRed : _borderGreen)
                        .withValues(alpha: 0.5)),
              ),
              child: Text(
                hasViolation ? '${worker.violationCount} violations' : 'Safe',
                style: TextStyle(
                    color: hasViolation ? _borderRed : _borderGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Shared card shell ─────────────────────────────────────────────────────────

class _DashCard extends StatelessWidget {
  const _DashCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2D3748), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(message,
            style: const TextStyle(color: _textSecondary, fontSize: 12)),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/report_data.dart';
import '../../data/services/api/worker_api.dart';

/// Data model for worker violation stats.
@immutable
class WorkerViolationStats {
  final String workerId;
  final String name;
  final String? photoUrl;
  final int violationCount;
  final int totalDetections;

  const WorkerViolationStats({
    required this.workerId,
    required this.name,
    this.photoUrl,
    required this.violationCount,
    required this.totalDetections,
  });

  double get complianceRate {
    if (totalDetections == 0) return 100.0;
    return ((totalDetections - violationCount) / totalDetections * 100).clamp(0, 100);
  }

  factory WorkerViolationStats.fromJson(Map<String, dynamic> json) {
    return WorkerViolationStats(
      workerId: json['worker_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      photoUrl: json['photo_url'] as String?,
      violationCount: json['violation_count'] as int? ?? 0,
      totalDetections: json['total_detections'] as int? ?? 0,
    );
  }
}

/// Controller for reports screen managing safety analytics and metrics.
class ReportsController extends GetxController {
  /// Observable for report data
  final Rx<ReportData?> reportData = Rx<ReportData?>(null);

  /// Observable for live updates toggle
  final RxBool liveUpdates = false.obs;

  /// Observable for loading state
  final RxBool isLoading = false.obs;

  /// Observable for filter dialog visibility
  final RxBool showFilterDialog = false.obs;

  /// Observable for worker violation stats list
  final RxList<WorkerViolationStats> workerStats = <WorkerViolationStats>[].obs;

  /// Observable for overall stats
  final RxMap<String, dynamic> overallStats = <String, dynamic>{}.obs;

  /// Timer for live updates
  Timer? _liveUpdatesTimer;

  /// Worker API service
  late final WorkerApi _workerApi;

  @override
  void onInit() {
    super.onInit();
    _workerApi = Get.find<WorkerApi>();
    loadReportData();
    loadWorkerStats();
  }

  /// Loads report data from API.
  Future<void> loadReportData() async {
    try {
      isLoading.value = true;

      // Fetch overall stats from API
      final data = await _workerApi.getWorkerStats();
      overallStats.value = data;

      // Parse data for ReportData
      final totalViolations = data['total_violations'] as int? ?? 0;
      final complianceRate = data['compliance_rate'] as double? ?? 0.0;
      final previousViolations = data['previous_violations'] as int? ?? totalViolations;

      // Calculate trend
      final incidentsTrend = previousViolations > 0
          ? ((totalViolations - previousViolations) / previousViolations * 100)
          : 0.0;

      // Get chart data (last 7 days)
      final chartData = _parseChartData(data['daily_stats'] as List<dynamic>?);

      reportData.value = ReportData(
        incidents: totalViolations,
        incidentsTrend: incidentsTrend,
        compliance: complianceRate.round(),
        complianceTrend: 0.0,
        dateRange: DateRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        ),
        chartData: chartData,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      // Handle error silently for now
    } finally {
      isLoading.value = false;
    }
  }

  /// Loads worker violation stats from API.
  Future<void> loadWorkerStats() async {
    try {
      final data = await _workerApi.getViolationsSummary();
      workerStats.value = data
          .map((json) => WorkerViolationStats.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Keep empty list on error
    }
  }

  /// Parses chart data from API response.
  List<ChartDataPoint> _parseChartData(List<dynamic>? dailyStats) {
    if (dailyStats == null || dailyStats.isEmpty) {
      // Return mock data if API doesn't provide daily stats
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days.map((day) {
        return ChartDataPoint(label: day, value: (95 + day.length).toDouble());
      }).toList();
    }

    return dailyStats.map((stat) {
      final data = stat as Map<String, dynamic>;
      final dateStr = data['date'] as String? ?? '';
      final compliance = data['compliance_rate'] as double? ?? 0.0;

      // Parse date to get day label
      String dayLabel = '';
      try {
        final date = DateTime.parse(dateStr);
        dayLabel = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      } catch (e) {
        dayLabel = 'Day';
      }

      return ChartDataPoint(label: dayLabel, value: compliance.roundToDouble());
    }).toList();
  }

  /// Toggles live updates on/off.
  void toggleLiveUpdates() {
    liveUpdates.value = !liveUpdates.value;

    if (liveUpdates.value) {
      _startLiveUpdates();
    } else {
      _stopLiveUpdates();
    }
  }

  /// Starts live updates timer.
  void _startLiveUpdates() {
    _liveUpdatesTimer?.cancel();
    _liveUpdatesTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => loadReportData(),
    );
  }

  /// Stops live updates timer.
  void _stopLiveUpdates() {
    _liveUpdatesTimer?.cancel();
    _liveUpdatesTimer = null;
  }

  /// Opens filter dialog.
  void openFilterDialog() {
    showFilterDialog.value = true;
  }

  /// Closes filter dialog.
  void closeFilterDialog() {
    showFilterDialog.value = false;
  }

  /// Gets trend color based on value (positive=green, negative=red).
  Color getTrendColor(double trend) {
    return trend >= 0 ? AppColors.success : AppColors.error;
  }

  /// Gets trend icon based on value.
  IconData getTrendIcon(double trend) {
    return trend >= 0 ? Icons.trending_up : Icons.trending_down;
  }

  /// Gets formatted trend string with percentage.
  String getFormattedTrend(double trend) {
    return '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}%';
  }

  @override
  void onClose() {
    _stopLiveUpdates();
    reportData.close();
    liveUpdates.close();
    isLoading.close();
    showFilterDialog.close();
    workerStats.close();
    overallStats.close();
    super.onClose();
  }
}

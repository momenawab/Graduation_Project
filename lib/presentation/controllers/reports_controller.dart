import 'dart:async';
import 'package:get/get.dart';
import '../../data/services/api/api_client.dart';
import '../../core/constants/api_constants.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DailyViolation {
  final DateTime date;
  final int count;
  const DailyViolation({required this.date, required this.count});
}

class DeptViolation {
  final String department;
  final int count;
  const DeptViolation({required this.department, required this.count});
}

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
    return ((totalDetections - violationCount) / totalDetections * 100)
        .clamp(0, 100);
  }

  factory WorkerViolationStats.fromJson(Map<String, dynamic> json) {
    return WorkerViolationStats(
      workerId: json['worker_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      photoUrl: json['photo_url'] as String?,
      violationCount: json['violation_count'] as int? ?? 0,
      totalDetections: json['total_detections'] as int? ?? 0,
    );
  }
}

class ReportsController extends GetxController {
  late final ApiClient _api;

  // KPI observables
  final RxInt totalWorkers = 0.obs;
  final RxInt totalViolations = 0.obs;
  final RxDouble complianceRate = 0.0.obs;
  final RxDouble highRiskPercent = 0.0.obs;

  // Chart data
  final RxList<DailyViolation> dailyViolations = <DailyViolation>[].obs;
  final RxList<DeptViolation> violationsByDept = <DeptViolation>[].obs;
  final RxInt violatedWorkers = 0.obs;
  final RxInt compliantWorkers = 0.obs;

  // Worker list
  final RxList<WorkerViolationStats> workerStats = <WorkerViolationStats>[].obs;

  // UI state
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final RxBool liveUpdates = false.obs;
  final RxString selectedDept = 'All'.obs;
  final RxString selectedRisk = 'All'.obs;

  Timer? _timer;

  // Filter options derived from data
  List<String> get departments =>
      ['All', ...violationsByDept.map((d) => d.department)];

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<ApiClient>();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    error.value = '';
    await Future.wait([loadDashboard(), loadWorkerStats()]);
    isLoading.value = false;
  }

  Future<void> loadDashboard() async {
    try {
      final resp = await _api.dio
          .get('${ApiConstants.apiPath}${ApiConstants.detectionDashboard}');
      final data = resp.data as Map<String, dynamic>;

      totalWorkers.value = data['total_workers'] as int? ?? 0;
      totalViolations.value = data['total_violations'] as int? ?? 0;
      complianceRate.value =
          (data['compliance_rate'] as num?)?.toDouble() ?? 0.0;
      highRiskPercent.value =
          (data['high_risk_percent'] as num?)?.toDouble() ?? 0.0;

      final daily = data['daily_violations'] as List<dynamic>? ?? [];
      dailyViolations.value = daily.map((e) {
        final m = e as Map<String, dynamic>;
        return DailyViolation(
          date: DateTime.parse(m['date'] as String),
          count: m['count'] as int? ?? 0,
        );
      }).toList();

      final depts = data['violations_by_department'] as List<dynamic>? ?? [];
      violationsByDept.value = depts.map((e) {
        final m = e as Map<String, dynamic>;
        return DeptViolation(
          department: m['department'] as String? ?? 'Unknown',
          count: m['count'] as int? ?? 0,
        );
      }).toList();

      final status = data['violation_status'] as Map<String, dynamic>? ?? {};
      violatedWorkers.value = status['violated'] as int? ?? 0;
      compliantWorkers.value = status['compliant'] as int? ?? 0;
    } catch (_) {}
  }

  Future<void> loadWorkerStats() async {
    try {
      final resp = await _api.dio
          .get('${ApiConstants.apiPath}/workers/violations-summary/');
      final list = resp.data as List<dynamic>;
      workerStats.value = list
          .map((e) =>
              WorkerViolationStats.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  void toggleLiveUpdates() {
    liveUpdates.value = !liveUpdates.value;
    if (liveUpdates.value) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => loadAll());
    } else {
      _timer?.cancel();
    }
  }

  void openFilterDialog() {}

  // Legacy helpers kept for compatibility
  Color getTrendColor(double trend) =>
      trend >= 0 ? AppColors.success : AppColors.error;
  IconData getTrendIcon(double trend) =>
      trend >= 0 ? Icons.trending_up : Icons.trending_down;
  String getFormattedTrend(double trend) =>
      '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}%';

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

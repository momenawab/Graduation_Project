import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/report_data.dart';
import '../../routes/app_routes.dart';

/// Controller for reports screen managing safety analytics and metrics.
@immutable
class ReportsController extends GetxController {
  /// Observable for report data
  final Rx<ReportData?> reportData = Rx<ReportData?>(null);

  /// Observable for live updates toggle
  final RxBool liveUpdates = false.obs;

  /// Observable for loading state
  final RxBool isLoading = false.obs;

  /// Observable for filter dialog visibility
  final RxBool showFilterDialog = false.obs;

  /// Timer for live updates
  Timer? _liveUpdatesTimer;

  /// Loads report data from API or cache.
  Future<void> loadReportData() async {
    try {
      isLoading.value = true;
      // TODO: Fetch actual report data from API
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for now
      reportData.value = ReportData(
        incidents: 12,
        incidentsTrend: -5.0,
        compliance: 98,
        complianceTrend: 2.0,
        dateRange: DateRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        ),
        chartData: [
          const ChartDataPoint(label: 'Mon', value: 96),
          const ChartDataPoint(label: 'Tue', value: 97),
          const ChartDataPoint(label: 'Wed', value: 94),
          const ChartDataPoint(label: 'Thu', value: 98),
          const ChartDataPoint(label: 'Fri', value: 95),
          const ChartDataPoint(label: 'Sat', value: 99),
          const ChartDataPoint(label: 'Sun', value: 97),
        ],
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      // Handle error silently for now
    } finally {
      isLoading.value = false;
    }
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
  void onInit() {
    super.onInit();
    loadReportData();
  }

  @override
  void onClose() {
    _stopLiveUpdates();
    reportData.close();
    liveUpdates.close();
    isLoading.close();
    showFilterDialog.close();
    super.onClose();
  }
}

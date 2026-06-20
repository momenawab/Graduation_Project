import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/system_status.dart';
import '../../data/services/api/camera_api.dart';
import '../../data/services/api/report_api.dart';
import '../../data/services/api/alert_api.dart';
import '../../routes/app_routes.dart';

/// Controller for home screen managing dashboard state and navigation.
@immutable
class HomeController extends GetxController {
  /// Observable for system status
  final Rx<SystemStatus> systemStatus = Rx<SystemStatus>(
    SystemStatus(
      status: SystemHealth.normal,
      activeCameras: 4,
      lastUpdate: DateTime.now(),
      message: 'All systems normal',
    ),
  );

  /// Observable for function card status (enabled/disabled states)
  final RxList<bool> cardStatus = RxList<bool>.filled(6, true);

  /// Live KPI values for the dashboard chips (fetched from the backend).
  final RxInt complianceRate = 0.obs; // percent, 0–100
  final RxInt alertCount = 0.obs; // outstanding/total alerts
  final RxBool statsLoaded = false.obs;

  /// Observable for SOS button state
  final RxBool sosActive = false.obs;

  /// Observable for loading state
  final RxBool isLoading = false.obs;

  /// Navigates to monitoring screen.
  void navigateToMonitoring() {
    Get.toNamed(AppRoutes.MONITORING);
  }

  /// Navigates to add worker screen.
  void navigateToAddWorker() {
    Get.toNamed(AppRoutes.ADD_WORKER);
  }

  /// Navigates to upload detection screen.
  void navigateToUploadDetection() {
    Get.toNamed(AppRoutes.UPLOAD_DETECTION);
  }

  /// Navigates to reports screen.
  void navigateToReports() {
    Get.toNamed(AppRoutes.REPORTS);
  }

  /// Navigates to the thresholds / alert configuration screen.
  void navigateToAlertConfig() {
    Get.toNamed(AppRoutes.ALERT_CONFIG);
  }

  /// Navigates to worker monitor screen.
  void navigateToWorkerMonitor() {
    Get.toNamed(AppRoutes.WORKER_MONITOR);
  }

  /// Navigates to the camera management screen.
  void navigateToCameras() {
    Get.toNamed(AppRoutes.CAMERA_MANAGEMENT);
  }

  /// Navigates to settings screen.
  void navigateToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }

  /// Handles SOS button press.
  void handleSOS() {
    sosActive.value = true;
    // TODO: Implement actual SOS alert functionality
    // - Send emergency alert to server
    // - Show confirmation dialog
    // - Log SOS event
    Future.delayed(const Duration(seconds: 2), () {
      sosActive.value = false;
    });
  }

  /// Refreshes system status and dashboard KPIs from the backend.
  ///
  /// Each source is fetched independently so one failing endpoint (or being
  /// offline) doesn't blank out the others; values simply stay at their last
  /// known state.
  Future<void> refreshSystemStatus() async {
    isLoading.value = true;

    int onlineCameras = systemStatus.value.activeCameras;

    // Cameras — count those reported online.
    if (Get.isRegistered<CameraApi>()) {
      try {
        final cameras = await Get.find<CameraApi>().getCameras();
        onlineCameras = cameras
            .where((c) =>
                c['status'] == 'online' || c['is_active'] == true)
            .length;
      } catch (_) {/* keep previous value */}
    }

    // Compliance rate from the reports summary.
    if (Get.isRegistered<ReportApi>()) {
      try {
        final summary = await Get.find<ReportApi>().getSummary();
        complianceRate.value = summary.compliance;
      } catch (_) {/* keep previous value */}
    }

    // Outstanding alert count.
    if (Get.isRegistered<AlertApi>()) {
      try {
        final stats = await Get.find<AlertApi>().getStats();
        final total = stats['total_alerts'] ??
            stats['pending_alerts'] ??
            stats['total'] ??
            0;
        alertCount.value = (total as num).toInt();
      } catch (_) {/* keep previous value */}
    }

    systemStatus.value = SystemStatus(
      status: SystemHealth.normal,
      activeCameras: onlineCameras,
      lastUpdate: DateTime.now(),
      message: 'All systems normal',
    );
    statsLoaded.value = true;
    isLoading.value = false;
  }

  /// Gets status color based on system health.
  Color getStatusColor() {
    switch (systemStatus.value.status) {
      case SystemHealth.normal:
        return const Color(0xFF4CAF50); // Green
      case SystemHealth.warning:
        return const Color(0xFFFFC107); // Yellow
      case SystemHealth.critical:
        return const Color(0xFFF44336); // Red
      case SystemHealth.offline:
        return const Color(0xFF757575); // Gray
    }
  }

  /// Gets status icon based on system health.
  IconData getStatusIcon() {
    switch (systemStatus.value.status) {
      case SystemHealth.normal:
        return Icons.check_circle;
      case SystemHealth.warning:
        return Icons.warning;
      case SystemHealth.critical:
        return Icons.error;
      case SystemHealth.offline:
        return Icons.cloud_off;
    }
  }

  @override
  void onInit() {
    super.onInit();
    refreshSystemStatus();
  }

  @override
  void onClose() {
    systemStatus.close();
    cardStatus.close();
    sosActive.close();
    isLoading.close();
    complianceRate.close();
    alertCount.close();
    statsLoaded.close();
    super.onClose();
  }
}

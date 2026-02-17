import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/system_status.dart';
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

  /// Observable for SOS button state
  final RxBool sosActive = false.obs;

  /// Observable for loading state
  final RxBool isLoading = false.obs;

  /// Navigates to monitoring screen (Coming Soon placeholder).
  void navigateToMonitoring() {
    Get.toNamed(
      '${AppRoutes.COMING_SOON}?icon=monitoring&title=Monitoring&description=Real-time PPE monitoring and detection streaming will be available soon.',
    );
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

  /// Navigates to alert config screen (Coming Soon placeholder).
  void navigateToAlertConfig() {
    Get.toNamed(
      '${AppRoutes.COMING_SOON}?icon=thresholds&title=Thresholds&description=Configure PPE compliance thresholds and alert settings.',
    );
  }

  /// Navigates to worker monitor screen.
  void navigateToWorkerMonitor() {
    Get.toNamed(AppRoutes.WORKER_MONITOR);
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

  /// Refreshes system status.
  Future<void> refreshSystemStatus() async {
    try {
      isLoading.value = true;
      // TODO: Fetch actual system status from API
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock update for now
      systemStatus.value = SystemStatus(
        status: SystemHealth.normal,
        activeCameras: 4,
        lastUpdate: DateTime.now(),
        message: 'All systems normal',
      );
    } catch (e) {
      // Handle error silently for now
    } finally {
      isLoading.value = false;
    }
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
    super.onClose();
  }
}

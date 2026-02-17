import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safesight/data/models/notification.dart' as models;
import 'package:safesight/data/models/detection_result.dart';
import 'package:safesight/data/models/worker.dart' as models;
import 'package:safesight/data/services/api/worker_api.dart';
import 'package:safesight/data/services/storage_service.dart';
import 'package:safesight/data/services/websocket/notification_stream.dart';
import 'package:safesight/routes/app_routes.dart';

/// Controller for Worker Home Screen.
///
/// Manages worker profile data, compliance status, and notifications.
class WorkerHomeController extends GetxController {
  /// Storage service
  StorageService get _storageService => Get.find<StorageService>();

  /// Worker API service
  late final WorkerApi _workerApi;

  /// Notification stream service
  late final NotificationStream _notificationStream;

  /// Worker data
  final Rx<models.Worker?> worker = Rx<models.Worker?>(null);

  /// Today's compliance status
  final Rx<ComplianceStatus> todayStatus = ComplianceStatus.unknown.obs;

  /// Violation count today
  final RxInt todayViolationCount = 0.obs;

  /// Total violation count
  final RxInt totalViolationCount = 0.obs;

  /// Notifications list
  final RxList<models.Notification> notifications = <models.Notification>[].obs;

  /// Unread notification count
  final RxInt unreadCount = 0.obs;

  /// Loading state
  final RxBool isLoading = true.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _workerApi = Get.find<WorkerApi>();
    _notificationStream = Get.find<NotificationStream>();
    _loadWorkerData();
    _connectNotifications();
  }

  @override
  void onClose() {
    _notificationStream.disconnect();
    super.onClose();
  }

  /// Load worker data from backend
  Future<void> _loadWorkerData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final workerId = _storageService.workerId;
      if (workerId == null) {
        // Not logged in as worker, redirect to login
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }

      // Fetch worker data
      final workerData = await _workerApi.getWorkerByWorkerId(workerId);
      worker.value = models.Worker.fromJson(workerData);

      // Load violations
      await _loadViolations();

    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load violation data
  Future<void> _loadViolations() async {
    try {
      final workerId = _storageService.workerId!;
      final response = await _workerApi.getWorkerViolations(workerId);

      // Extract violations list from response
      final violations = response['violations'] as List? ?? [];
      final totalViolations = response['total_violations'] as int? ?? violations.length;

      // Count today's violations
      final today = DateTime.now();
      final todayViolations = violations.where((v) {
        final vMap = v as Map<String, dynamic>;
        final timestamp = DateTime.tryParse(vMap['timestamp']?.toString() ?? '');
        return timestamp != null &&
          timestamp.year == today.year &&
          timestamp.month == today.month &&
          timestamp.day == today.day;
      }).length;

      todayViolationCount.value = todayViolations;
      totalViolationCount.value = totalViolations;

      // Determine compliance status
      if (todayViolations == 0) {
        todayStatus.value = ComplianceStatus.compliant;
      } else if (todayViolations <= 2) {
        todayStatus.value = ComplianceStatus.partial;
      } else {
        todayStatus.value = ComplianceStatus.nonCompliant;
      }

    } catch (e) {
      print('Error loading violations: $e');
    }
  }

  /// Connect to notification stream
  void _connectNotifications() {
    final userId = _storageService.userId ?? '0';
    final role = _storageService.userRole ?? 'worker';
    final workerId = _storageService.workerId;

    _notificationStream.connect(
      userId: userId,
      role: role,
      workerId: workerId,
    );

    // Listen to notifications
    _notificationStream.notificationStream.listen((notification) {
      notifications.insert(0, notification);
      if (!notification.read) {
        unreadCount.value++;
      }
      _showInAppNotification(notification);
    });

    // Load existing notifications from stream
    notifications.assignAll(_notificationStream.notifications);
    unreadCount.value = _notificationStream.unreadCount.value;
  }

  /// Show in-app notification based on severity
  void _showInAppNotification(models.Notification notification) {
    if (notification.severity == models.NotificationSeverity.high) {
      Get.snackbar(
        'PPE Violation Alert!',
        notification.body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        icon: const Icon(Icons.warning, color: Colors.white),
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        'PPE Reminder',
        notification.body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.surface,
        colorText: Get.theme.colorScheme.onSurface,
        icon: const Icon(Icons.info_outline),
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Navigate to notifications screen
  void goToNotifications() {
    Get.toNamed(AppRoutes.WORKER_NOTIFICATIONS);
  }

  /// Navigate to violations screen
  void goToViolations() {
    Get.toNamed(AppRoutes.WORKER_VIOLATIONS);
  }

  /// Refresh data
  Future<void> refresh() async {
    await _loadWorkerData();
  }

  /// Logout
  Future<void> logout() async {
    await _storageService.clearUserData();
    _notificationStream.disconnect();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}

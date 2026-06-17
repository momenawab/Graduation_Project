import 'package:get/get.dart';
import 'package:safesight/data/services/api/worker_api.dart';
import 'package:safesight/data/services/api/detection_api_service.dart';
import 'package:safesight/data/services/storage_service.dart';
import 'package:safesight/data/services/offline_cache.dart';
import 'package:safesight/routes/app_routes.dart';

/// Controller for Worker Violations Screen.
///
/// Shows worker's personal violation history.
class WorkerViolationsController extends GetxController {
  /// Storage service
  StorageService get _storageService => Get.find<StorageService>();

  /// Worker API service
  late final WorkerApi _workerApi;

  /// Violations list
  final RxList<Map<String, dynamic>> violations = <Map<String, dynamic>>[].obs;

  /// Loading state
  final RxBool isLoading = false.obs;

  /// Error message
  final RxString errorMessage = ''.obs;

  /// Filter by date range
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _workerApi = Get.find<WorkerApi>();
    _loadViolations();
  }

  @override
  void onClose() {
    super.onClose();
  }

  /// Load violations from backend
  Future<void> _loadViolations() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final workerId = _storageService.workerId;
      if (workerId == null) {
        // Not logged in as worker, redirect to login
        Get.offAllNamed(AppRoutes.LOGIN);
        return;
      }

      final response = await _workerApi.getWorkerViolations(workerId);
      final violationsList = response['violations'] as List? ?? [];
      violations.assignAll(violationsList.cast<Map<String, dynamic>>());
      // F11 — cache for offline use + flush any acks queued while offline.
      if (Get.isRegistered<OfflineCache>()) {
        await Get.find<OfflineCache>().put('violations_$workerId', violationsList);
        await _flushPendingAcks();
      }

    } catch (e) {
      // F11 — offline fallback: render last-cached violations if available.
      final workerId = _storageService.workerId;
      if (workerId != null && Get.isRegistered<OfflineCache>()) {
        final cached = Get.find<OfflineCache>().get('violations_$workerId');
        if (cached is List) {
          violations.assignAll(cached.cast<Map<String, dynamic>>());
          errorMessage.value = 'Offline — showing last saved data.';
        } else {
          errorMessage.value = e.toString();
        }
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh violations
  Future<void> refresh() async {
    await _loadViolations();
  }

  /// Get filtered violations based on selected filter
  List<Map<String, dynamic>> get filteredViolations {
    final all = violations.toList();

    switch (selectedFilter.value) {
      case 'today':
        final today = DateTime.now();
        return all.where((v) {
          final timestamp = DateTime.tryParse(v['timestamp']?.toString() ?? '');
          return timestamp != null &&
            timestamp.year == today.year &&
            timestamp.month == today.month &&
            timestamp.day == today.day;
        }).toList();
      case 'week':
        final weekAgo = DateTime.now().subtract(const Duration(days: 7));
        return all.where((v) {
          final timestamp = DateTime.tryParse(v['timestamp']?.toString() ?? '');
          return timestamp != null && timestamp.isAfter(weekAgo);
        }).toList();
      case 'month':
        final monthAgo = DateTime.now().subtract(const Duration(days: 30));
        return all.where((v) {
          final timestamp = DateTime.tryParse(v['timestamp']?.toString() ?? '');
          return timestamp != null && timestamp.isAfter(monthAgo);
        }).toList();
      default:
        return all;
    }
  }

  /// Set filter
  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  /// F11 — replay acknowledgements that were queued while offline.
  Future<void> _flushPendingAcks() async {
    final cache = Get.find<OfflineCache>();
    final pending = cache.pendingAcks;
    if (pending.isEmpty) return;
    final api = Get.find<DetectionApiService>();
    for (final id in pending) {
      try {
        await api.acknowledgeViolation(id);
      } catch (_) {
        return; // still offline — keep the queue for next time
      }
    }
    await cache.clearAcks();
  }

  /// F4 — acknowledge a violation ("I've corrected it").
  Future<void> acknowledge(String violationId) async {
    try {
      await Get.find<DetectionApiService>().acknowledgeViolation(violationId);
      // Reflect locally so the UI updates immediately.
      final i = violations.indexWhere((v) => v['violation_id'] == violationId);
      if (i != -1) {
        final updated = Map<String, dynamic>.from(violations[i]);
        updated['acknowledged_at'] = DateTime.now().toIso8601String();
        violations[i] = updated;
      }
      Get.snackbar('Acknowledged', 'Thanks — marked as seen.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      // F11 — offline: queue the ack to flush on reconnect.
      if (Get.isRegistered<OfflineCache>()) {
        await Get.find<OfflineCache>().queueAck(violationId);
        Get.snackbar('Saved offline', 'Will sync when back online.',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  /// Go back
  void goBack() {
    Get.back();
  }
}

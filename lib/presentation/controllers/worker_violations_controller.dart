import 'package:get/get.dart';
import 'package:safesight/data/services/api/worker_api.dart';
import 'package:safesight/data/services/storage_service.dart';
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

    } catch (e) {
      errorMessage.value = e.toString();
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

  /// Go back
  void goBack() {
    Get.back();
  }
}

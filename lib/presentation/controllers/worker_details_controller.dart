import 'package:get/get.dart';
import '../../data/services/api/worker_api.dart';

/// Controller for Worker Details screen.
class WorkerDetailsController extends GetxController {
  late final WorkerApi _workerApi;

  /// Worker ID from route parameters
  final String workerId;

  /// Observable for worker data
  final Rx<Map<String, dynamic>?> workerData = Rx<Map<String, dynamic>?>(null);

  /// Observable for violation records
  final RxList<Map<String, dynamic>> violations = <Map<String, dynamic>>[].obs;

  /// Observable for loading state
  final RxBool isLoading = true.obs;

  /// Observable for error message
  final RxString errorMessage = ''.obs;

  WorkerDetailsController({required this.workerId});

  /// Loads worker details and violations from the API.
  Future<void> loadWorkerDetails() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch worker details
      workerData.value = await _workerApi.getWorkerByWorkerId(workerId);

      // Fetch worker violations
      final data = await _workerApi.getWorkerViolations(workerId);
      violations.value = (data['violations'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
    } catch (e) {
      errorMessage.value = 'Failed to load worker details: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await loadWorkerDetails();
  }

  /// Calculates compliance rate based on violations.
  double get complianceRate {
    if (workerData.value == null) return 0.0;

    final totalDetections = workerData.value!['total_detections'] as int? ?? 0;
    final violationCount = workerData.value!['violation_count'] as int? ?? 0;

    if (totalDetections == 0) return 100.0;
    return ((totalDetections - violationCount) / totalDetections * 100).clamp(0, 100);
  }

  /// Gets compliance level text.
  String get complianceLevel {
    final rate = complianceRate;
    if (rate >= 95) return 'Excellent';
    if (rate >= 85) return 'Good';
    if (rate >= 70) return 'Fair';
    return 'Poor';
  }

  /// Gets compliance color.
  String get complianceColor {
    final rate = complianceRate;
    if (rate >= 95) return 'success';
    if (rate >= 85) return 'primary';
    if (rate >= 70) return 'warning';
    return 'error';
  }

  @override
  void onInit() {
    super.onInit();
    _workerApi = Get.find<WorkerApi>();
    loadWorkerDetails();
  }

  @override
  void onClose() {
    workerData.close();
    violations.close();
    isLoading.close();
    errorMessage.close();
    super.onClose();
  }
}

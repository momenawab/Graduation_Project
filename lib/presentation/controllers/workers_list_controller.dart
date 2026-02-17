import 'package:get/get.dart';
import '../../data/models/worker.dart' as model;
import '../../data/services/api/worker_api.dart';

/// Controller for Workers List screen.
class WorkersListController extends GetxController {
  late final WorkerApi _workerApi;

  /// Observable list of workers
  final RxList<model.Worker> workers = <model.Worker>[].obs;

  /// Observable for loading state
  final RxBool isLoading = false.obs;

  /// Observable for error message
  final RxString errorMessage = ''.obs;

  /// Observable for search query
  final RxString searchQuery = ''.obs;

  /// Filtered workers list based on search
  List<model.Worker> get filteredWorkers {
    if (searchQuery.value.isEmpty) {
      return workers;
    }
    final query = searchQuery.value.toLowerCase();
    return workers.where((worker) {
      return worker.fullName.toLowerCase().contains(query) ||
          worker.id.contains(query) ||
          worker.department.toLowerCase().contains(query);
    }).toList();
  }

  /// Loads workers from the API.
  Future<void> loadWorkers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _workerApi.getWorkers();
      workers.value = result;
    } catch (e) {
      errorMessage.value = 'Failed to load workers: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    await loadWorkers();
  }

  /// Updates the search query.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Gets violation count badge color based on count.
  String getViolationLevel(int count) {
    if (count == 0) return 'none';
    if (count <= 3) return 'low';
    if (count <= 7) return 'medium';
    return 'high';
  }

  @override
  void onInit() {
    super.onInit();
    _workerApi = Get.find<WorkerApi>();
    loadWorkers();
  }

  @override
  void onClose() {
    workers.close();
    isLoading.close();
    errorMessage.close();
    searchQuery.close();
    super.onClose();
  }
}

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

  /// True once per-worker violation counts have been merged from the backend.
  final RxBool statsLoaded = false.obs;

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
    // The list endpoint has no per-worker counts, so merge them from the
    // violations-summary endpoint (no backend change required).
    loadViolationCounts();
  }

  /// Fetches per-worker violation counts and merges them into [workers], so the
  /// card badges and the KPI chips show real data. Fails silently when offline.
  Future<void> loadViolationCounts() async {
    try {
      final summary = await _workerApi.getViolationsSummary();
      // Build a { worker_id -> violation_count } lookup.
      final counts = <String, int>{};
      for (final entry in summary) {
        if (entry is Map) {
          final id = entry['worker_id']?.toString();
          final count = (entry['violation_count'] as num?)?.toInt() ?? 0;
          if (id != null) counts[id] = count;
        }
      }
      // Merge into the loaded workers without dropping any.
      workers.value = workers
          .map((w) => w.copyWith(violationCount: counts[w.id] ?? 0))
          .toList();
      statsLoaded.value = true;
    } catch (_) {
      // Offline / unauthorized — leave counts at their last known values.
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
    statsLoaded.close();
    super.onClose();
  }
}

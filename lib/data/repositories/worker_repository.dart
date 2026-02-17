import '../models/worker.dart';
import '../services/api/worker_api.dart';

/// Worker repository for worker data access with caching.
///
/// This repository provides methods to access worker data through the API
/// and implements caching using Hive for offline support.
class WorkerRepository {
  /// The Worker API instance
  final WorkerApi workerApi;

  /// Creates a new WorkerRepository instance.
  WorkerRepository({required this.workerApi});

  /// Gets a list of all workers.
  Future<List<Worker>> getWorkers() async {
    // TODO: Implement Hive caching
    // final box = await Hive.openBox<Worker>('workers');
    // final cached = box.values.toList();
    // if (cached.isNotEmpty) {
    //   return cached;
    // }

    final workers = await workerApi.getWorkers();

    // TODO: Cache the result
    // await box.clear();
    // for (final worker in workers) {
    //   await box.put(worker.id, worker);
    // }

    return workers;
  }

  /// Gets a single worker by ID.
  Future<Worker?> getWorker(String id) async {
    // TODO: Implement Hive caching
    // final box = await Hive.openBox<Worker>('workers');
    // final cached = box.get(id);
    // if (cached != null) {
    //   return cached;
    // }

    try {
      return await workerApi.getWorker(id);
    } catch (e) {
      return null;
    }
  }

  /// Creates a new worker.
  Future<Worker> createWorker(Worker worker) async {
    final created = await workerApi.createWorker(worker);

    // TODO: Cache the result
    // final box = await Hive.openBox<Worker>('workers');
    // await box.put(created.id, created);

    return created;
  }

  /// Updates an existing worker.
  Future<Worker> updateWorker(Worker worker) async {
    final updated = await workerApi.updateWorker(worker);

    // TODO: Update cache
    // final box = await Hive.openBox<Worker>('workers');
    // await box.put(updated.id, updated);

    return updated;
  }

  /// Deletes a worker by ID.
  Future<void> deleteWorker(String id) async {
    await workerApi.deleteWorker(id);

    // TODO: Remove from cache
    // final box = await Hive.openBox<Worker>('workers');
    // await box.delete(id);
  }

  /// Gets a list of all departments.
  Future<List<String>> getDepartments() async {
    return await workerApi.getDepartments();
  }

  /// Gets a list of all job titles.
  Future<List<String>> getJobTitles() async {
    return await workerApi.getJobTitles();
  }

  /// Checks if a worker ID already exists.
  Future<bool> workerIdExists(String id) async {
    final workers = await getWorkers();
    return workers.any((worker) => worker.id == id);
  }
}

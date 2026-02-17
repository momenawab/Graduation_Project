import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import '../models/worker.dart';
import '../models/report_data.dart';
import '../models/upload_result.dart';

/// Cache service for offline data storage using Hive.
///
/// Provides boxes for workers, reports, and upload results.
@immutable
class CacheService {
  /// Box names
  static const String _workersBoxName = 'workers';
  static const String _reportsBoxName = 'reports';
  static const String _uploadsBoxName = 'uploads';

  /// Hive boxes
  late Box<Worker> _workersBox;
  late Box<ReportData> _reportsBox;
  late Box<UploadDetectionResult> _uploadsBox;

  /// Singleton instance
  static CacheService? _instance;

  /// Private constructor
  CacheService._();

  /// Gets the singleton instance of CacheService.
  static Future<CacheService> getInstance() async {
    if (_instance == null) {
      final instance = CacheService._();
      await instance._initialize();
      _instance = instance;
    }
    return _instance!;
  }

  /// Initializes Hive boxes.
  Future<void> _initialize() async {
    await Hive.openBox<Worker>(_workersBoxName);
    await Hive.openBox<ReportData>(_reportsBoxName);
    await Hive.openBox<UploadDetectionResult>(_uploadsBoxName);

    _workersBox = Hive.box<Worker>(_workersBoxName);
    _reportsBox = Hive.box<ReportData>(_reportsBoxName);
    _uploadsBox = Hive.box<UploadDetectionResult>(_uploadsBoxName);
  }

  // Worker Cache Methods

  /// Gets all cached workers.
  List<Worker> getCachedWorkers() {
    return _workersBox.values.toList();
  }

  /// Gets a specific worker by ID.
  Worker? getCachedWorker(String id) {
    return _workersBox.get(id);
  }

  /// Saves a worker to cache.
  Future<void> cacheWorker(Worker worker) async {
    await _workersBox.put(worker.id, worker);
  }

  /// Saves multiple workers to cache.
  Future<void> cacheWorkers(List<Worker> workers) async {
    await _workersBox.putAll({for (var worker in workers) worker.id: worker});
  }

  /// Deletes a worker from cache.
  Future<void> deleteWorker(String id) async {
    await _workersBox.delete(id);
  }

  /// Clears all workers from cache.
  Future<void> clearWorkers() async {
    await _workersBox.clear();
  }

  // Report Cache Methods

  /// Gets cached report data.
  ReportData? getCachedReport() {
    return _reportsBox.get('latest');
  }

  /// Saves report data to cache.
  Future<void> cacheReport(ReportData report) async {
    await _reportsBox.put('latest', report);
  }

  /// Clears report data from cache.
  Future<void> clearReport() async {
    await _reportsBox.clear();
  }

  // Upload Result Cache Methods

  /// Gets all cached upload results.
  List<UploadDetectionResult> getCachedUploads() {
    return _uploadsBox.values.toList();
  }

  /// Gets a specific upload result by image ID.
  UploadDetectionResult? getCachedUpload(String imageId) {
    return _uploadsBox.get(imageId);
  }

  /// Saves an upload result to cache.
  Future<void> cacheUpload(UploadDetectionResult result) async {
    await _uploadsBox.put(result.imageId, result);
  }

  /// Deletes an upload result from cache.
  Future<void> deleteUpload(String imageId) async {
    await _uploadsBox.delete(imageId);
  }

  /// Clears all upload results from cache.
  Future<void> clearUploads() async {
    await _uploadsBox.clear();
  }

  // General Cache Methods

  /// Clears all cached data.
  Future<void> clearAll() async {
    await _workersBox.clear();
    await _reportsBox.clear();
    await _uploadsBox.clear();
  }

  /// Gets cache statistics.
  Map<String, int> getCacheStats() {
    return {
      'workers': _workersBox.length,
      'reports': _reportsBox.length,
      'uploads': _uploadsBox.length,
    };
  }

  /// Disposes all Hive boxes.
  Future<void> dispose() async {
    await _workersBox.close();
    await _reportsBox.close();
    await _uploadsBox.close();
  }
}

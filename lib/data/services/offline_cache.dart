import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// F11 — lightweight JSON offline cache (Hive). Lets screens render last-known
/// data when offline, and queues acknowledgements to flush on reconnect.
///
/// Kept separate from the (typed) CacheService to avoid Hive TypeAdapter
/// codegen; this stores plain JSON strings keyed by string.
class OfflineCache extends GetxService {
  static const String _boxName = 'offline_cache';
  static const String _ackQueueKey = '_pending_acks';
  late final Box _box;

  Future<OfflineCache> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    return this;
  }

  Future<void> put(String key, dynamic value) async {
    try {
      await _box.put(key, jsonEncode(value));
    } catch (_) {/* ignore cache write errors */}
  }

  dynamic get(String key) {
    final raw = _box.get(key);
    if (raw is String) {
      try {
        return jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  List<String> get pendingAcks =>
      ((_box.get(_ackQueueKey) as List?) ?? const []).cast<String>();

  Future<void> queueAck(String violationId) async {
    final q = pendingAcks..add(violationId);
    await _box.put(_ackQueueKey, q);
  }

  Future<void> clearAcks() async => _box.put(_ackQueueKey, <String>[]);
}

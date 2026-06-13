import '../../../core/constants/api_constants.dart';
import '../../models/alert_config.dart';
import 'api_client.dart';

/// Alert API — wired to the SafeSight Django alerts endpoints.
///
/// Note on read-state: marking notifications read/unread is handled in real
/// time over the `/ws/notifications/` WebSocket (`mark_read` message), so the
/// REST-side mark-read methods here are best-effort no-ops kept for API
/// compatibility with existing controllers.
class AlertApi {
  /// The API client instance
  final ApiClient apiClient;

  /// Creates a new AlertApi instance.
  AlertApi({required this.apiClient});

  /// Per-alert delivery preferences are persisted inside the user's
  /// notification-preferences blob under this key.
  static const String _configKey = 'flutterAlertConfigs';

  /// Gets all alert delivery configurations for the current user.
  Future<List<AlertConfig>> getConfig() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.notificationPreferences.fullPath,
    );
    final list = (response.data?[_configKey] as List?) ?? const [];
    return list
        .map((e) => AlertConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Updates a single alert configuration and persists the full set.
  Future<AlertConfig> updateConfig(AlertConfig config) async {
    final current = await getConfig();
    final next = [
      for (final c in current)
        if (c.alertType != config.alertType) c,
      config,
    ];
    await apiClient.put<Map<String, dynamic>>(
      ApiConstants.notificationPreferences.fullPath,
      data: {_configKey: next.map((c) => c.toJson()).toList()},
    );
    return config;
  }

  /// Gets alert history.
  /// GET /api/alerts/history/
  Future<List<Map<String, dynamic>>> getHistory() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.alertHistory.fullPath,
    );
    final data = response.data ?? {};
    final results = (data['results'] ?? data['history'] ?? []) as List;
    return results.cast<Map<String, dynamic>>();
  }

  /// Alert delivery stats (KPI tiles).
  /// GET /api/alerts/stats/
  Future<Map<String, dynamic>> getStats() async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiConstants.alertStats.fullPath,
    );
    return response.data ?? <String, dynamic>{};
  }

  /// Marks an alert as read — handled via the notifications WebSocket.
  Future<void> markAsRead(String alertId) async {
    // Read-state is driven by NotificationStream over the WebSocket.
  }

  /// Marks all alerts as read — handled via the notifications WebSocket.
  Future<void> markAllAsRead() async {
    // Read-state is driven by NotificationStream over the WebSocket.
  }

  /// Deletes an alert. The backend exposes no per-history delete endpoint.
  Future<void> deleteAlert(String alertId) async {
    // No-op: alert history is immutable on the backend.
  }

  /// Sends a test alert.
  /// POST /api/alerts/test/
  Future<Map<String, dynamic>> testAlert(AlertConfig config) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      ApiConstants.alertTest.fullPath,
      data: {'alert_type': config.alertType.name},
    );
    return response.data ?? {'success': true};
  }
}

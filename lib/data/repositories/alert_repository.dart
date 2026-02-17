import '../models/alert_config.dart';
import '../services/api/alert_api.dart';

/// Alert repository for alert configuration data access.
///
/// This repository provides methods to access alert configuration data through API.
class AlertRepository {
  /// The Alert API instance
  final AlertApi alertApi;

  /// Creates a new AlertRepository instance.
  AlertRepository({required this.alertApi});

  /// Gets all alert configurations.
  Future<List<AlertConfig>> getAlertConfigs() async {
    return await alertApi.getConfig();
  }

  /// Updates an alert configuration.
  Future<AlertConfig> updateAlertConfig(AlertConfig config) async {
    return await alertApi.updateConfig(config);
  }

  /// Gets alert history.
  Future<List<Map<String, dynamic>>> getAlertHistory() async {
    return await alertApi.getHistory();
  }

  /// Marks an alert as read.
  Future<void> markAlertAsRead(String alertId) async {
    await alertApi.markAsRead(alertId);
  }

  /// Marks all alerts as read.
  Future<void> markAllAlertsAsRead() async {
    await alertApi.markAllAsRead();
  }

  /// Deletes an alert.
  Future<void> deleteAlert(String alertId) async {
    await alertApi.deleteAlert(alertId);
  }

  /// Tests an alert configuration.
  Future<Map<String, dynamic>> testAlertConfig(AlertConfig config) async {
    return await alertApi.testAlert(config);
  }
}

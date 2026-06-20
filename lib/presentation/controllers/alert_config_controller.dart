import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/alert_config.dart';
import '../../core/constants/app_colors.dart';

/// Controller for alert configuration screen managing alert preferences.
@immutable
class AlertConfigController extends GetxController {
  /// Observable for all alert configurations
  final RxList<AlertConfig> alertConfigs = RxList<AlertConfig>([
    // Safety Critical Systems (Priority: critical)
    AlertConfig(
      alertType: AlertType.stealthMode,
      enabled: true,
      deliveryMode: DeliveryMode.dual,
      priority: AlertPriority.critical,
    ),
    AlertConfig(
      alertType: AlertType.ppeCompliance,
      enabled: true,
      deliveryMode: DeliveryMode.dual,
      priority: AlertPriority.critical,
    ),
    AlertConfig(
      alertType: AlertType.proxWarning,
      enabled: true,
      deliveryMode: DeliveryMode.haptic,
      priority: AlertPriority.critical,
    ),
    AlertConfig(
      alertType: AlertType.zoneIncursion,
      enabled: true,
      deliveryMode: DeliveryMode.dual,
      priority: AlertPriority.critical,
    ),
    // Intelligence Feed (Priority: normal)
    AlertConfig(
      alertType: AlertType.safetyMetrics,
      enabled: true,
      deliveryMode: DeliveryMode.audio,
      priority: AlertPriority.normal,
    ),
    AlertConfig(
      alertType: AlertType.systemStatus,
      enabled: true,
      deliveryMode: DeliveryMode.audio,
      priority: AlertPriority.normal,
    ),
  ]);

  /// Observable for loading state
  final RxBool isLoading = false.obs;

  /// Observable for commit success
  final RxBool commitSuccess = false.obs;

  /// Observable for error message
  final RxString errorMessage = ''.obs;

  /// Gets alert config by type
  AlertConfig getConfigByType(AlertType type) {
    return alertConfigs.firstWhere(
      (config) => config.alertType == type,
      orElse: () => AlertConfig(
        alertType: type,
        enabled: false,
        deliveryMode: DeliveryMode.audio,
        priority: AlertPriority.normal,
      ),
    );
  }

  /// Toggles alert enabled state
  void toggleAlert(AlertType type) {
    final index = alertConfigs.indexWhere((config) => config.alertType == type);
    if (index != -1) {
      final current = alertConfigs[index];
      alertConfigs[index] = current.copyWith(enabled: !current.enabled);
      alertConfigs.refresh();
    }
  }

  /// Sets delivery mode for an alert type
  void setDeliveryMode(AlertType type, DeliveryMode mode) {
    final index = alertConfigs.indexWhere((config) => config.alertType == type);
    if (index != -1) {
      final current = alertConfigs[index];
      alertConfigs[index] = current.copyWith(deliveryMode: mode);
      alertConfigs.refresh();
    }
  }

  /// Gets safety critical systems configs
  List<AlertConfig> get safetyCriticalSystems => alertConfigs
      .where((config) => config.priority == AlertPriority.critical)
      .toList();

  /// Gets intelligence feed configs
  List<AlertConfig> get intelligenceFeed => alertConfigs
      .where((config) => config.priority == AlertPriority.normal)
      .toList();

  /// Gets display name for alert type
  String getAlertTypeName(AlertType type) {
    switch (type) {
      case AlertType.ppeCompliance:
        return 'PPE Compliance';
      case AlertType.proxWarning:
        return 'Proximity Warning';
      case AlertType.stealthMode:
        return 'Stealth Mode';
      case AlertType.zoneIncursion:
        return 'Zone Incursion';
      case AlertType.safetyMetrics:
        return 'Safety Metrics';
      case AlertType.systemStatus:
        return 'System Status';
    }
  }

  /// Gets icon for alert type
  IconData getAlertTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.ppeCompliance:
        return Icons.shield;
      case AlertType.proxWarning:
        return Icons.warning;
      case AlertType.stealthMode:
        return Icons.notifications;
      case AlertType.zoneIncursion:
        return Icons.location_on;
      case AlertType.safetyMetrics:
        return Icons.bar_chart;
      case AlertType.systemStatus:
        return Icons.refresh;
    }
  }

  /// Gets color for enabled state
  Color getEnabledColor(bool enabled) {
    return enabled ? AppColors.accent : AppColors.textDisabled;
  }

  /// Gets color for delivery mode selection
  Color getDeliveryModeColor(DeliveryMode mode, DeliveryMode selected) {
    return mode == selected ? AppColors.accent : AppColors.textDisabled;
  }

  /// Commits all alert configuration changes
  Future<void> commitChanges() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      commitSuccess.value = false;

      // TODO: Save to API
      // await AlertApi.updateConfig(alertConfigs.toList());

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));

      // TODO: Save to local storage
      // await _saveToLocal();

      commitSuccess.value = true;

      // Show success message
      Get.snackbar(
        'Success',
        'Alert configurations saved successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Reset success after delay
      Future.delayed(const Duration(seconds: 2), () {
        commitSuccess.value = false;
      });
    } catch (e) {
      errorMessage.value = 'Failed to save alert configurations: $e';

      Get.snackbar(
        'Error',
        errorMessage.value,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resets all configs to default
  void resetToDefaults() {
    alertConfigs.value = [
      // Safety Critical Systems
      AlertConfig(
        alertType: AlertType.stealthMode,
        enabled: true,
        deliveryMode: DeliveryMode.dual,
        priority: AlertPriority.critical,
      ),
      AlertConfig(
        alertType: AlertType.ppeCompliance,
        enabled: true,
        deliveryMode: DeliveryMode.dual,
        priority: AlertPriority.critical,
      ),
      AlertConfig(
        alertType: AlertType.proxWarning,
        enabled: true,
        deliveryMode: DeliveryMode.haptic,
        priority: AlertPriority.critical,
      ),
      AlertConfig(
        alertType: AlertType.zoneIncursion,
        enabled: true,
        deliveryMode: DeliveryMode.dual,
        priority: AlertPriority.critical,
      ),
      // Intelligence Feed
      AlertConfig(
        alertType: AlertType.safetyMetrics,
        enabled: true,
        deliveryMode: DeliveryMode.audio,
        priority: AlertPriority.normal,
      ),
      AlertConfig(
        alertType: AlertType.systemStatus,
        enabled: true,
        deliveryMode: DeliveryMode.audio,
        priority: AlertPriority.normal,
      ),
    ];
  }

  @override
  void onInit() {
    super.onInit();
    // TODO: Load from local storage
    // _loadFromLocal();
  }

  @override
  void onClose() {
    alertConfigs.close();
    isLoading.close();
    commitSuccess.close();
    errorMessage.close();
    super.onClose();
  }
}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Enum representing types of alerts.
enum AlertType {
  ppeCompliance,
  proxWarning,
  stealthMode,
  zoneIncursion,
  safetyMetrics,
  systemStatus,
}

/// Enum representing alert delivery modes.
enum DeliveryMode {
  /// Sound only
  audio,

  /// Vibration only
  haptic,

  /// Both sound and vibration
  dual,
}

/// Enum representing alert priority.
enum AlertPriority {
  /// Safety critical systems
  critical,

  /// Intelligence feed
  normal,
}

/// Model representing user's notification preferences for a single alert type.
@immutable
class AlertConfig extends Equatable {
  /// Type of alert
  final AlertType alertType;

  /// Is alert active
  final bool enabled;

  /// How to deliver alert
  final DeliveryMode deliveryMode;

  /// Alert importance
  final AlertPriority priority;

  const AlertConfig({
    required this.alertType,
    required this.enabled,
    required this.deliveryMode,
    required this.priority,
  });

  /// Creates an AlertConfig instance from JSON data.
  factory AlertConfig.fromJson(Map<String, dynamic> json) {
    return AlertConfig(
      alertType: AlertType.values.byName(json['alertType'] as String),
      enabled: json['enabled'] as bool,
      deliveryMode: DeliveryMode.values.byName(json['deliveryMode'] as String),
      priority: AlertPriority.values.byName(json['priority'] as String),
    );
  }

  /// Converts AlertConfig instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'alertType': alertType.name,
      'enabled': enabled,
      'deliveryMode': deliveryMode.name,
      'priority': priority.name,
    };
  }

  /// Creates a copy of this AlertConfig with optionally updated fields.
  AlertConfig copyWith({
    AlertType? alertType,
    bool? enabled,
    DeliveryMode? deliveryMode,
    AlertPriority? priority,
  }) {
    return AlertConfig(
      alertType: alertType ?? this.alertType,
      enabled: enabled ?? this.enabled,
      deliveryMode: deliveryMode ?? this.deliveryMode,
      priority: priority ?? this.priority,
    );
  }

  @override
  List<Object?> get props => [alertType, enabled, deliveryMode, priority];

  @override
  String toString() =>
      'AlertConfig(type: $alertType, enabled: $enabled, mode: $deliveryMode)';
}

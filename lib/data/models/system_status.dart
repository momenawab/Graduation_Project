import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Enum representing overall system health status.
enum SystemHealth {
  /// All systems operational
  normal,

  /// Minor issues
  warning,

  /// Major issues
  critical,

  /// System unavailable
  offline,
}

/// Model representing overall system health status for home dashboard.
@immutable
class SystemStatus extends Equatable {
  /// Overall system state
  final SystemHealth status;

  /// Number of active camera feeds
  final int activeCameras;

  /// Last status update timestamp
  final DateTime lastUpdate;

  /// Human-readable status message
  final String message;

  const SystemStatus({
    required this.status,
    required this.activeCameras,
    required this.lastUpdate,
    required this.message,
  });

  /// Creates a SystemStatus instance from JSON data.
  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      status: SystemHealth.values.byName(json['status'] as String),
      activeCameras: json['activeCameras'] as int,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      message: json['message'] as String,
    );
  }

  /// Converts SystemStatus instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'activeCameras': activeCameras,
      'lastUpdate': lastUpdate.toIso8601String(),
      'message': message,
    };
  }

  /// Creates a copy of this SystemStatus with optionally updated fields.
  SystemStatus copyWith({
    SystemHealth? status,
    int? activeCameras,
    DateTime? lastUpdate,
    String? message,
  }) {
    return SystemStatus(
      status: status ?? this.status,
      activeCameras: activeCameras ?? this.activeCameras,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, activeCameras, lastUpdate, message];

  @override
  String toString() => 'SystemStatus(status: $status, cameras: $activeCameras)';
}

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Notification type enum
enum NotificationType {
  violation,
  violationResolved,
  systemAlert,
}

/// Notification severity enum
enum NotificationSeverity {
  low,
  high,
  critical,
}

/// Notification model for PPE violation alerts and system notifications.
@immutable
class Notification extends Equatable {
  /// Unique notification identifier
  final String id;

  /// Type of notification
  final NotificationType type;

  /// Severity level (for violation notifications)
  final NotificationSeverity severity;

  /// Worker ID (if applicable)
  final String? workerId;

  /// Worker name (if applicable)
  final String? workerName;

  /// List of missing PPE items (for violation notifications)
  final List<String> missingPpe;

  /// List of required PPE items (for violation notifications)
  final List<String> requiredPpe;

  /// Image URL (for violation notifications)
  final String? imageUrl;

  /// Timestamp when notification was created
  final DateTime timestamp;

  /// Whether the notification has been read
  final bool read;

  /// Additional message (for system alerts)
  final String? message;

  const Notification({
    required this.id,
    required this.type,
    required this.severity,
    this.workerId,
    this.workerName,
    this.missingPpe = const [],
    this.requiredPpe = const [],
    this.imageUrl,
    required this.timestamp,
    this.read = false,
    this.message,
  });

  /// Creates a Notification instance from JSON data.
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['notification_id'] as String? ?? json['id'] as String? ?? '',
      type: _parseNotificationType(json['type'] as String? ?? 'violation_notification'),
      severity: _parseSeverity(json['severity'] as String? ?? 'low'),
      workerId: json['worker_id'] as String?,
      workerName: json['worker_name'] as String?,
      missingPpe: (json['missing_ppe'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      requiredPpe: (json['required_ppe'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      imageUrl: json['image_url'] as String?,
      timestamp: DateTime.parse(
        json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
      read: json['read'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  /// Creates a violation notification from detection data
  factory Notification.violation({
    required String workerId,
    required String workerName,
    required List<String> missingPpe,
    required List<String> requiredPpe,
    String? imageUrl,
    DateTime? timestamp,
  }) {
    final requiredCount = requiredPpe.length;
    final missingCount = missingPpe.length;

    // Calculate severity
    NotificationSeverity severity;
    if (requiredCount > 0 && (missingCount / requiredCount) >= 0.5) {
      severity = NotificationSeverity.high;
    } else {
      severity = NotificationSeverity.low;
    }

    return Notification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.violation,
      severity: severity,
      workerId: workerId,
      workerName: workerName,
      missingPpe: missingPpe,
      requiredPpe: requiredPpe,
      imageUrl: imageUrl,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'violation_notification':
      case 'violation':
        return NotificationType.violation;
      case 'violation_resolved':
        return NotificationType.violationResolved;
      case 'system_alert':
        return NotificationType.systemAlert;
      default:
        return NotificationType.violation;
    }
  }

  static NotificationSeverity _parseSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return NotificationSeverity.low;
      case 'high':
        return NotificationSeverity.high;
      case 'critical':
        return NotificationSeverity.critical;
      default:
        return NotificationSeverity.low;
    }
  }

  /// Converts Notification instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': _typeToString(),
      'severity': _severityToString(),
      'worker_id': workerId,
      'worker_name': workerName,
      'missing_ppe': missingPpe,
      'required_ppe': requiredPpe,
      'image_url': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'read': read,
      'message': message,
    };
  }

  String _typeToString() {
    switch (type) {
      case NotificationType.violation:
        return 'violation_notification';
      case NotificationType.violationResolved:
        return 'violation_resolved';
      case NotificationType.systemAlert:
        return 'system_alert';
    }
  }

  String _severityToString() {
    switch (severity) {
      case NotificationSeverity.low:
        return 'low';
      case NotificationSeverity.high:
        return 'high';
      case NotificationSeverity.critical:
        return 'critical';
    }
  }

  /// Creates a copy of this Notification with optionally updated fields.
  Notification copyWith({
    String? id,
    NotificationType? type,
    NotificationSeverity? severity,
    String? workerId,
    String? workerName,
    List<String>? missingPpe,
    List<String>? requiredPpe,
    String? imageUrl,
    DateTime? timestamp,
    bool? read,
    String? message,
  }) {
    return Notification(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      workerId: workerId ?? this.workerId,
      workerName: workerName ?? this.workerName,
      missingPpe: missingPpe ?? this.missingPpe,
      requiredPpe: requiredPpe ?? this.requiredPpe,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      read: read ?? this.read,
      message: message ?? this.message,
    );
  }

  /// Mark notification as read
  Notification markAsRead() {
    return copyWith(read: true);
  }

  /// Get display title for the notification
  String get title {
    switch (type) {
      case NotificationType.violation:
        return severity == NotificationSeverity.high
            ? 'High Priority Violation!'
            : 'PPE Violation Detected';
      case NotificationType.violationResolved:
        return 'Violation Resolved';
      case NotificationType.systemAlert:
        return 'System Alert';
    }
  }

  /// Get display body for the notification
  String get body {
    switch (type) {
      case NotificationType.violation:
        final worker = workerName ?? workerId ?? 'Unknown';
        final ppeList = missingPpe.join(', ');
        return '$worker is missing: $ppeList';
      case NotificationType.violationResolved:
        return 'A violation has been marked as resolved';
      case NotificationType.systemAlert:
        return message ?? 'System notification';
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        severity,
        workerId,
        workerName,
        missingPpe,
        requiredPpe,
        imageUrl,
        timestamp,
        read,
        message,
      ];

  @override
  String toString() =>
      'Notification(id: $id, type: $type, severity: $severity, worker: $workerName)';
}

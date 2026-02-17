import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Enum representing types of Personal Protective Equipment.
enum PPEType {
  hardHat,
  safetyGlasses,
  vest,
  gloves,
  steelToedBoots,
  earProtection,
  hat,
}

/// Enum representing the detection status of a PPE item.
enum PPEStatus {
  /// Correct PPE detected
  compliant,

  /// Required PPE not detected
  missing,

  /// Wrong type detected
  notSuitable,

  /// This PPE not required for worker
  notRequired,
}

/// Model representing a single PPE item and its detection status.
@immutable
class PPEItem extends Equatable {
  /// Type of PPE
  final PPEType type;

  /// Current detection status
  final PPEStatus status;

  /// Last time this PPE was detected (optional)
  final DateTime? lastDetected;

  const PPEItem({required this.type, required this.status, this.lastDetected});

  /// Creates a PPEItem instance from JSON data.
  factory PPEItem.fromJson(Map<String, dynamic> json) {
    return PPEItem(
      type: PPEType.values.byName(json['type'] as String),
      status: PPEStatus.values.byName(json['status'] as String),
      lastDetected: json['lastDetected'] != null
          ? DateTime.parse(json['lastDetected'] as String)
          : null,
    );
  }

  /// Converts PPEItem instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'status': status.name,
      'lastDetected': lastDetected?.toIso8601String(),
    };
  }

  /// Creates a copy of this PPEItem with optionally updated fields.
  PPEItem copyWith({PPEType? type, PPEStatus? status, DateTime? lastDetected}) {
    return PPEItem(
      type: type ?? this.type,
      status: status ?? this.status,
      lastDetected: lastDetected ?? this.lastDetected,
    );
  }

  @override
  List<Object?> get props => [type, status, lastDetected];

  @override
  String toString() => 'PPEItem(type: $type, status: $status)';
}

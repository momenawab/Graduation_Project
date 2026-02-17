import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'ppe_item.dart';

/// Worker model representing a registered worker/personnel in the system.
@immutable
class Worker extends Equatable {
  /// Unique worker identifier (8 digits)
  final String id;

  /// Worker's full name (2-100 characters)
  final String fullName;

  /// Department name
  final String department;

  /// Job title/role
  final String jobTitle;

  /// Required PPE for this role
  final List<PPEType> requiredPpe;

  /// Face recognition template ID (optional, future use)
  final String? faceId;

  /// Registration timestamp
  final DateTime createdAt;

  /// Total PPE violations
  final int violationCount;

  const Worker({
    required this.id,
    required this.fullName,
    required this.department,
    required this.jobTitle,
    required this.requiredPpe,
    this.faceId,
    required this.createdAt,
    this.violationCount = 0,
  });

  /// Creates a Worker instance from JSON data.
  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      department: json['department'] as String,
      jobTitle: json['jobTitle'] as String,
      requiredPpe: (json['requiredPpe'] as List)
          .map((e) => PPEType.values.byName(e as String))
          .toList(),
      faceId: json['faceId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      violationCount: json['violationCount'] as int? ?? 0,
    );
  }

  /// Converts Worker instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'department': department,
      'jobTitle': jobTitle,
      'requiredPpe': requiredPpe.map((e) => e.name).toList(),
      'faceId': faceId,
      'createdAt': createdAt.toIso8601String(),
      'violationCount': violationCount,
    };
  }

  /// Creates a copy of this Worker with optionally updated fields.
  Worker copyWith({
    String? id,
    String? fullName,
    String? department,
    String? jobTitle,
    List<PPEType>? requiredPpe,
    String? faceId,
    DateTime? createdAt,
    int? violationCount,
  }) {
    return Worker(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      requiredPpe: requiredPpe ?? this.requiredPpe,
      faceId: faceId ?? this.faceId,
      createdAt: createdAt ?? this.createdAt,
      violationCount: violationCount ?? this.violationCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    department,
    jobTitle,
    requiredPpe,
    faceId,
    createdAt,
    violationCount,
  ];

  @override
  String toString() =>
      'Worker(id: $id, name: $fullName, department: $department)';
}

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
      id: json['worker_id'] as String? ?? json['id'] as String,
      fullName: json['name'] as String? ?? json['fullName'] as String,
      department: json['department'] as String? ?? '',
      jobTitle: json['position'] as String? ?? json['jobTitle'] as String? ?? '',
      requiredPpe: json['required_ppe'] != null
          ? (json['required_ppe'] as List)
              .map((e) => _parsePPEType(e as String))
              .toList()
          : (json['requiredPpe'] as List?)
              ?.map((e) => _parsePPEType(e as String))
              .toList() ?? [],
      faceId: json['faceId'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      violationCount: json['violationCount'] as int? ?? 0,
    );
  }

  /// Parse PPE type from string, handling backend naming
  static PPEType _parsePPEType(String value) {
    // Map backend PPE names to enum values
    final mapping = {
      'hardHat': PPEType.hardHat,
      'safetyGlasses': PPEType.safetyGlasses,
      'vest': PPEType.vest,
      'gloves': PPEType.gloves,
      'steelToedBoots': PPEType.steelToedBoots,
      'earProtection': PPEType.earProtection,
    };
    return mapping[value] ?? PPEType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PPEType.hardHat,
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

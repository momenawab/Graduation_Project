import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'ppe_item.dart';

/// Enum representing overall compliance status.
enum ComplianceStatus {
  /// All required PPE present
  compliant,

  /// Some PPE missing
  partial,

  /// Critical PPE missing
  nonCompliant,
}

/// Model representing a bounding box for detection.
@immutable
class BoundingBox extends Equatable {
  /// Left coordinate (0-1 relative)
  final double x;

  /// Top coordinate (0-1 relative)
  final double y;

  /// Width (0-1 relative)
  final double width;

  /// Height (0-1 relative)
  final double height;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Creates a BoundingBox instance from JSON data.
  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  /// Converts BoundingBox instance to JSON.
  Map<String, dynamic> toJson() {
    return {'x': x, 'y': y, 'width': width, 'height': height};
  }

  /// Creates a copy of this BoundingBox with optionally updated fields.
  BoundingBox copyWith({double? x, double? y, double? width, double? height}) {
    return BoundingBox(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [x, y, width, height];

  @override
  String toString() => 'BoundingBox(x: $x, y: $y, w: $width, h: $height)';
}

/// Model representing a single person detection.
@immutable
class PersonDetection extends Equatable {
  /// Worker identifier ("Unknown" if not recognized)
  final String? workerId;

  /// Detection coordinates
  final BoundingBox boundingBox;

  /// Each PPE item status
  final List<PPEItem> ppeStatus;

  /// Overall compliance status
  final ComplianceStatus overallStatus;

  /// Detection confidence (0-1)
  final double confidence;

  const PersonDetection({
    this.workerId,
    required this.boundingBox,
    required this.ppeStatus,
    required this.overallStatus,
    required this.confidence,
  });

  /// Creates a PersonDetection instance from JSON data.
  factory PersonDetection.fromJson(Map<String, dynamic> json) {
    return PersonDetection(
      workerId: json['workerId'] as String?,
      boundingBox: BoundingBox.fromJson(
        json['boundingBox'] as Map<String, dynamic>,
      ),
      ppeStatus: (json['ppeStatus'] as List)
          .map((e) => PPEItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      overallStatus: ComplianceStatus.values.byName(
        json['overallStatus'] as String,
      ),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  /// Converts PersonDetection instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'boundingBox': boundingBox.toJson(),
      'ppeStatus': ppeStatus.map((e) => e.toJson()).toList(),
      'overallStatus': overallStatus.name,
      'confidence': confidence,
    };
  }

  /// Creates a copy of this PersonDetection with optionally updated fields.
  PersonDetection copyWith({
    String? workerId,
    BoundingBox? boundingBox,
    List<PPEItem>? ppeStatus,
    ComplianceStatus? overallStatus,
    double? confidence,
  }) {
    return PersonDetection(
      workerId: workerId ?? this.workerId,
      boundingBox: boundingBox ?? this.boundingBox,
      ppeStatus: ppeStatus ?? this.ppeStatus,
      overallStatus: overallStatus ?? this.overallStatus,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  List<Object?> get props => [
    workerId,
    boundingBox,
    ppeStatus,
    overallStatus,
    confidence,
  ];

  @override
  String toString() =>
      'PersonDetection(workerId: $workerId, status: $overallStatus)';
}

/// Model representing a single detection frame result from AI service.
@immutable
class DetectionResult extends Equatable {
  /// Unique frame identifier
  final String frameId;

  /// Total persons detected
  final int detected;

  /// Fully compliant persons
  final int compliant;

  /// Persons with violations
  final int nonCompliant;

  /// Individual detection details
  final List<PersonDetection> detections;

  const DetectionResult({
    required this.frameId,
    required this.detected,
    required this.compliant,
    required this.nonCompliant,
    required this.detections,
  });

  /// Creates a DetectionResult instance from JSON data.
  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      frameId: json['frameId'] as String,
      detected: json['detected'] as int,
      compliant: json['compliant'] as int,
      nonCompliant: json['nonCompliant'] as int,
      detections: (json['detections'] as List)
          .map((e) => PersonDetection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts DetectionResult instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'frameId': frameId,
      'detected': detected,
      'compliant': compliant,
      'nonCompliant': nonCompliant,
      'detections': detections.map((e) => e.toJson()).toList(),
    };
  }

  /// Creates a copy of this DetectionResult with optionally updated fields.
  DetectionResult copyWith({
    String? frameId,
    int? detected,
    int? compliant,
    int? nonCompliant,
    List<PersonDetection>? detections,
  }) {
    return DetectionResult(
      frameId: frameId ?? this.frameId,
      detected: detected ?? this.detected,
      compliant: compliant ?? this.compliant,
      nonCompliant: nonCompliant ?? this.nonCompliant,
      detections: detections ?? this.detections,
    );
  }

  @override
  List<Object?> get props => [
    frameId,
    detected,
    compliant,
    nonCompliant,
    detections,
  ];

  @override
  String toString() =>
      'DetectionResult(frameId: $frameId, detected: $detected, compliant: $compliant)';
}

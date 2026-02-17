import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'ppe_item.dart';

/// Enum representing analysis status.
enum AnalysisStatus {
  /// Waiting to be analyzed
  pending,

  /// Currently processing
  analyzing,

  /// Analysis complete
  completed,

  /// Analysis failed
  failed,
}

/// Model representing result of manual image upload for PPE analysis.
@immutable
class UploadDetectionResult extends Equatable {
  /// Uploaded image identifier
  final String imageId;

  /// URL to uploaded image
  final String imageUrl;

  /// Current analysis state
  final AnalysisStatus analysisStatus;

  /// Overall compliance percentage (0-100)
  final int? complianceScore;

  /// Each PPE item result
  final List<PPEItem> ppeResults;

  /// Analysis completion time (optional)
  final DateTime? analyzedAt;

  /// Number of people detected
  final int? detectedCount;

  /// Number of compliant people
  final int? compliantCount;

  /// Number of non-compliant people
  final int? nonCompliantCount;

  const UploadDetectionResult({
    required this.imageId,
    required this.imageUrl,
    required this.analysisStatus,
    this.complianceScore,
    required this.ppeResults,
    this.analyzedAt,
    this.detectedCount,
    this.compliantCount,
    this.nonCompliantCount,
  });

  /// Creates an UploadDetectionResult instance from JSON data.
  factory UploadDetectionResult.fromJson(Map<String, dynamic> json) {
    return UploadDetectionResult(
      imageId: json['imageId'] as String,
      imageUrl: json['imageUrl'] as String,
      analysisStatus: AnalysisStatus.values.byName(
        json['analysisStatus'] as String,
      ),
      complianceScore: json['complianceScore'] as int?,
      ppeResults: (json['ppeResults'] as List)
          .map((e) => PPEItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.parse(json['analyzedAt'] as String)
          : null,
      detectedCount: json['detectedCount'] as int?,
      compliantCount: json['compliantCount'] as int?,
      nonCompliantCount: json['nonCompliantCount'] as int?,
    );
  }

  /// Converts UploadDetectionResult instance to JSON.
  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'imageUrl': imageUrl,
      'analysisStatus': analysisStatus.name,
      'complianceScore': complianceScore,
      'ppeResults': ppeResults.map((e) => e.toJson()).toList(),
      'analyzedAt': analyzedAt?.toIso8601String(),
      'detectedCount': detectedCount,
      'compliantCount': compliantCount,
      'nonCompliantCount': nonCompliantCount,
    };
  }

  /// Creates a copy of this UploadDetectionResult with optionally updated fields.
  UploadDetectionResult copyWith({
    String? imageId,
    String? imageUrl,
    AnalysisStatus? analysisStatus,
    int? complianceScore,
    List<PPEItem>? ppeResults,
    DateTime? analyzedAt,
    int? detectedCount,
    int? compliantCount,
    int? nonCompliantCount,
  }) {
    return UploadDetectionResult(
      imageId: imageId ?? this.imageId,
      imageUrl: imageUrl ?? this.imageUrl,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      complianceScore: complianceScore ?? this.complianceScore,
      ppeResults: ppeResults ?? this.ppeResults,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      detectedCount: detectedCount ?? this.detectedCount,
      compliantCount: compliantCount ?? this.compliantCount,
      nonCompliantCount: nonCompliantCount ?? this.nonCompliantCount,
    );
  }

  @override
  List<Object?> get props => [
    imageId,
    imageUrl,
    analysisStatus,
    complianceScore,
    ppeResults,
    analyzedAt,
    detectedCount,
    compliantCount,
    nonCompliantCount,
  ];

  @override
  String toString() =>
      'UploadDetectionResult(id: $imageId, status: $analysisStatus)';
}

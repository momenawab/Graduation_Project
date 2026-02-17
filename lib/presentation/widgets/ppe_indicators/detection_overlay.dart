import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/detection_result.dart';

/// Widget for displaying detection overlay with bounding boxes and PPE status.
@immutable
class DetectionOverlay extends StatelessWidget {
  /// Detection result to display
  final DetectionResult detectionResult;

  /// Image width (for bounding box calculation)
  final double imageWidth;

  /// Image height (for bounding box calculation)
  final double imageHeight;

  /// Whether to show worker IDs (defaults to true)
  final bool showWorkerIds;

  /// Whether to show confidence scores (defaults to true)
  final bool showConfidence;

  const DetectionOverlay({
    required this.detectionResult,
    required this.imageWidth,
    required this.imageHeight,
    this.showWorkerIds = true,
    this.showConfidence = true,
  });

  @override
  Widget build(BuildContext context) {
    if (detectionResult.detected == 0) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        ...detectionResult.detections.map((detection) {
          final box = detection.boundingBox;
          final rect = _calculateBoundingBox(box);

          return Positioned(
            left: rect.left,
            top: rect.top,
            width: rect.width,
            height: rect.height,
            child: _buildDetectionBox(detection),
          );
        }),
      ],
    );
  }

  Widget _buildDetectionBox(PersonDetection detection) {
    final config = _getDetectionConfig(detection);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: config.borderColor, width: 2),
        borderRadius: BorderRadius.circular(4),
        color: config.overlayColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showWorkerIds && detection.workerId != null) ...[
            _buildInfoBadge(
              label: 'ID: ${detection.workerId}',
              backgroundColor: config.backgroundColor,
            ),
          ],
          if (showConfidence) ...[
            _buildInfoBadge(
              label: '${(detection.confidence * 100).toStringAsFixed(0)}%',
              backgroundColor: config.backgroundColor.withOpacity(0.8),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required String label,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Rect _calculateBoundingBox(BoundingBox box) {
    return Rect.fromLTWH(
      box.x * imageWidth,
      box.y * imageHeight,
      box.width * imageWidth,
      box.height * imageHeight,
    );
  }

  _DetectionConfig _getDetectionConfig(PersonDetection detection) {
    switch (detection.overallStatus) {
      case ComplianceStatus.compliant:
        return _DetectionConfig(
          borderColor: AppColors.success,
          overlayColor: AppColors.compliantOverlay,
          backgroundColor: AppColors.success,
        );
      case ComplianceStatus.partial:
        return _DetectionConfig(
          borderColor: AppColors.warning,
          overlayColor: AppColors.partialOverlay,
          backgroundColor: AppColors.warning,
        );
      case ComplianceStatus.nonCompliant:
        return _DetectionConfig(
          borderColor: AppColors.error,
          overlayColor: AppColors.violationOverlay,
          backgroundColor: AppColors.error,
        );
    }
  }
}

@immutable
class _DetectionConfig {
  final Color borderColor;
  final Color overlayColor;
  final Color backgroundColor;

  const _DetectionConfig({
    required this.borderColor,
    required this.overlayColor,
    required this.backgroundColor,
  });
}

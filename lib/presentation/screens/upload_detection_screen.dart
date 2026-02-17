import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/upload_controller.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/top_app_bar.dart';
import '../widgets/ppe_indicators/compliance_badge.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/detection_result.dart';
import '../../data/models/ppe_item.dart';

/// Screen for manual PPE detection via image upload.
class UploadDetectionScreen extends GetView<UploadController> {
  const UploadDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(
        title: AppStrings.uploadDetection,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if (!controller.hasImage.value) {
            return _buildEmptyState(context);
          } else if (controller.isAnalyzing.value) {
            return _buildAnalyzingState(context);
          } else if (controller.analysisResult.value != null) {
            return _buildResultState(context);
          } else {
            return _buildPreviewState(context);
          }
        }),
      ),
    );
  }

  /// Build empty state when no image is selected
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 80,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 24),
          Text(
            'Upload an image to analyze PPE compliance',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                text: 'Camera',
                icon: Icons.camera_alt,
                onPressed: () => controller.pickImageFromCamera(),
              ),
              const SizedBox(width: 16),
              AppButton(
                text: 'Gallery',
                icon: Icons.photo_library,
                onPressed: () => controller.pickImageFromGallery(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build preview state when image is selected but not yet analyzed
  Widget _buildPreviewState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 24),
          _buildConfidenceSlider(),
          const SizedBox(height: 24),
          AppButton(
            text: 'Analyze Image',
            icon: Icons.analytics,
            onPressed: () => controller.scanImage(),
            width: double.infinity,
          ),
          const SizedBox(height: 16),
          AppButton(
            text: 'Cancel',
            isDisabled: true,
            onPressed: () => controller.resetScan(),
            width: double.infinity,
            backgroundColor: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  /// Build analyzing state during analysis
  Widget _buildAnalyzingState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 24),
          _buildAnalyzingStatus(),
          const SizedBox(height: 32),
          _buildAnalysisIcons(),
          const SizedBox(height: 32),
          Obx(
            () => LinearProgressIndicator(
              value: controller.uploadProgress.value,
              backgroundColor: AppColors.cardBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build result state after analysis is complete
  Widget _buildResultState(BuildContext context) {
    final result = controller.detectionResult.value!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 16),
          _buildSummaryHeader(result),
          const SizedBox(height: 24),
          ...result.detections.asMap().entries.map((entry) {
            final index = entry.key;
            final detection = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildWorkerCard(detection, index + 1),
            );
          }),
          const SizedBox(height: 16),
          AppButton(
            text: AppStrings.initiateNewScan,
            onPressed: () => controller.resetScan(),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  /// Build summary header with overall stats
  Widget _buildSummaryHeader(DetectionResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            '${result.detections.length}',
            'Workers',
            Icons.people_outline_rounded,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildSummaryItem(
            '${result.compliant}',
            'Compliant',
            Icons.check_circle_outline_rounded,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildSummaryItem(
            '${result.nonCompliant}',
            'Violations',
            Icons.warning_amber_rounded,
          ),
        ],
      ),
    );
  }

  /// Build summary item for header
  Widget _buildSummaryItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  /// Build worker card with individual PPE status
  Widget _buildWorkerCard(PersonDetection detection, int workerNumber) {
    final complianceScore = _calculateWorkerComplianceScore(detection);
    final statusColor = _getWorkerStatusColor(detection.overallStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worker header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Worker $workerNumber',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (detection.workerId != null &&
                        detection.workerId!.isNotEmpty)
                      Text(
                        'ID: ${detection.workerId}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              _buildWorkerStatusBadge(detection.overallStatus, complianceScore),
            ],
          ),
          const SizedBox(height: 16),
          // PPE items list
          ...detection.ppeStatus.map((ppe) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildWorkerPPEItem(ppe),
            );
          }),
        ],
      ),
    );
  }

  /// Build worker status badge
  Widget _buildWorkerStatusBadge(ComplianceStatus status, int score) {
    final color = _getWorkerStatusColor(status);
    final label = _getWorkerStatusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getWorkerStatusIcon(status),
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                '$score%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build worker PPE item
  Widget _buildWorkerPPEItem(PPEItem ppe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildPPEStatusIcon(ppe.status),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getPPELabel(ppe.type),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            _getStatusText(ppe.status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(ppe.status),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate compliance score for a single worker
  int _calculateWorkerComplianceScore(PersonDetection detection) {
    if (detection.ppeStatus.isEmpty) return 0;

    final compliant = detection.ppeStatus
        .where((item) => item.status == PPEStatus.compliant)
        .length;
    return ((compliant / detection.ppeStatus.length) * 100).round();
  }

  /// Get worker status color
  Color _getWorkerStatusColor(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return AppColors.success;
      case ComplianceStatus.partial:
        return AppColors.warning;
      case ComplianceStatus.nonCompliant:
        return AppColors.error;
    }
  }

  /// Get worker status icon
  IconData _getWorkerStatusIcon(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return Icons.check_circle;
      case ComplianceStatus.partial:
        return Icons.warning;
      case ComplianceStatus.nonCompliant:
        return Icons.cancel;
    }
  }

  /// Get worker status label
  String _getWorkerStatusLabel(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return 'Compliant';
      case ComplianceStatus.partial:
        return 'Partial';
      case ComplianceStatus.nonCompliant:
        return 'Violation';
    }
  }

  /// Build image preview area
  Widget _buildImagePreview() {
    return Obx(() {
      final image = controller.selectedImage.value;
      if (image == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(image, fit: BoxFit.cover, width: double.infinity),
        ),
      );
    });
  }

  /// Build confidence threshold slider
  Widget _buildConfidenceSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Confidence Threshold',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getThresholdColor(
                    controller.confidenceThreshold.value,
                  ).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(controller.confidenceThreshold.value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _getThresholdColor(
                      controller.confidenceThreshold.value,
                    ),
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final thresholdColor = _getThresholdColor(
              controller.confidenceThreshold.value,
            );
            return Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    activeTrackColor: thresholdColor,
                    inactiveTrackColor: thresholdColor.withOpacity(0.2),
                    thumbColor: thresholdColor,
                    overlayColor: thresholdColor.withOpacity(0.2),
                    valueIndicatorColor: thresholdColor,
                    valueIndicatorTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Slider(
                    value: controller.confidenceThreshold.value,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: '${(controller.confidenceThreshold.value * 100).toInt()}%',
                    onChanged: (value) {
                      controller.confidenceThreshold.value = value;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildThresholdLabel('More\nDetections', AppColors.warning),
                    _buildThresholdLabel('Fewer\nDetections', AppColors.success),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getThresholdHint(controller.confidenceThreshold.value),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get color based on threshold value
  Color _getThresholdColor(double value) {
    if (value < 0.3) return AppColors.warning;
    if (value < 0.6) return AppColors.primary;
    return AppColors.success;
  }

  /// Build threshold label
  Widget _buildThresholdLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color.withOpacity(0.7),
        height: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Get hint text based on threshold value
  String _getThresholdHint(double value) {
    if (value < 0.3) {
      return 'Low threshold: Maximum sensitivity. May detect items with lower confidence.';
    } else if (value < 0.6) {
      return 'Medium threshold: Balanced sensitivity. Recommended for general use.';
    } else {
      return 'High threshold: Only high-confidence detections. Fewer false positives.';
    }
  }

  /// Build analyzing status text
  Widget _buildAnalyzingStatus() {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.analyzingInfrastructure,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build three circular analysis icons
  Widget _buildAnalysisIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildAnalysisIcon(
          Icons.engineering,
          AppStrings.analyzeHardHat,
          AppColors.primary,
        ),
        _buildAnalysisIcon(
          Icons.visibility,
          AppStrings.analyzeSafetyGlasses,
          AppColors.primary,
        ),
        _buildAnalysisIcon(
          Icons.hearing,
          AppStrings.analyzeEarProtection,
          AppColors.primary,
        ),
      ],
    );
  }

  /// Build single analysis icon
  Widget _buildAnalysisIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build PPE status icon
  Widget _buildPPEStatusIcon(PPEStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case PPEStatus.compliant:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case PPEStatus.missing:
        icon = Icons.cancel;
        color = AppColors.error;
        break;
      case PPEStatus.notSuitable:
        icon = Icons.warning;
        color = AppColors.warning;
        break;
      case PPEStatus.notRequired:
        icon = Icons.block;
        color = AppColors.textSecondary;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  /// Get PPE label
  String _getPPELabel(PPEType type) {
    switch (type) {
      case PPEType.hardHat:
        return 'Hard Hat';
      case PPEType.safetyGlasses:
        return 'Safety Glasses';
      case PPEType.vest:
        return 'Safety Vest';
      case PPEType.gloves:
        return 'Gloves';
      case PPEType.steelToedBoots:
        return 'Steel-toed Boots';
      case PPEType.earProtection:
        return 'Ear Protection';
      case PPEType.hat:
        return 'Hat';
    }
  }

  /// Get status text
  String _getStatusText(PPEStatus status) {
    switch (status) {
      case PPEStatus.compliant:
        return 'Compliant';
      case PPEStatus.missing:
        return 'Missing';
      case PPEStatus.notSuitable:
        return 'Not Suitable';
      case PPEStatus.notRequired:
        return 'Not Required';
    }
  }

  /// Get status color
  Color _getStatusColor(PPEStatus status) {
    switch (status) {
      case PPEStatus.compliant:
        return AppColors.success;
      case PPEStatus.missing:
        return AppColors.error;
      case PPEStatus.notSuitable:
        return AppColors.warning;
      case PPEStatus.notRequired:
        return AppColors.textSecondary;
    }
  }
}

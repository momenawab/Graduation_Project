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
    final result = controller.analysisResult.value!;
    final complianceScore = result.complianceScore ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(),
          const SizedBox(height: 24),
          _buildComplianceBadge(complianceScore),
          const SizedBox(height: 32),
          _buildPPEStatusList(result.ppeResults),
          const SizedBox(height: 32),
          AppButton(
            text: AppStrings.initiateNewScan,
            onPressed: () => controller.resetScan(),
            width: double.infinity,
          ),
        ],
      ),
    );
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
              color: AppColors.textSecondary.withValues(alpha: 0.1),
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
            color: color.withValues(alpha: 0.2),
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

  /// Build compliance badge
  Widget _buildComplianceBadge(int complianceScore) {
    final status = complianceScore >= 90
        ? ComplianceStatus.compliant
        : complianceScore >= 70
        ? ComplianceStatus.partial
        : ComplianceStatus.nonCompliant;

    return Column(
      children: [
        ComplianceBadge(
          status: status,
          compliancePercentage: complianceScore,
          size: 100,
          customLabel: AppStrings.complianceSecured,
        ),
        const SizedBox(height: 8),
        Text(
          '$complianceScore%',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Build PPE status list
  Widget _buildPPEStatusList(List<dynamic> ppeResults) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PPE Analysis Results',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...ppeResults.map((item) {
            if (item is! PPEItem) return const SizedBox.shrink();
            final ppeItem = item as PPEItem;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  _buildPPEStatusIcon(ppeItem.status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getPPELabel(ppeItem.type),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    _getStatusText(ppeItem.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(ppeItem.status),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/worker_monitor_controller.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/top_app_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/detection_result.dart';
import '../../data/models/ppe_item.dart';

/// Screen for Workers Monitor feature.
/// Upload an image to identify workers (face recognition) and check PPE compliance.
class WorkerMonitorScreen extends StatelessWidget {
  const WorkerMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<WorkerMonitorController>()
        ? Get.find<WorkerMonitorController>()
        : Get.put(WorkerMonitorController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: TopAppBar(
        title: 'Workers Monitor',
        showBackButton: true,
      ),
      body: SafeArea(
        child: Obx(() {
          // Touch all state-machine observables so Obx always tracks them,
          // even when the chosen branch delegates to nested Obx widgets.
          final hasImage = controller.hasImage.value;
          final isAnalyzing = controller.isAnalyzing.value;
          final result = controller.detectionResult.value;

          if (!hasImage) {
            return _buildEmptyState(controller);
          } else if (isAnalyzing) {
            return _buildAnalyzingState(controller);
          } else if (result != null) {
            return _buildResultState(controller);
          } else {
            return _buildPreviewState(controller);
          }
        }),
      ),
    );
  }

  /// Empty state - camera/gallery buttons, description text.
  Widget _buildEmptyState(WorkerMonitorController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Scan & Identify Workers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload an image to identify workers using face recognition and check their PPE compliance.',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
            if (controller.errorMessage.value.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                controller.errorMessage.value,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Preview state - image preview, confidence slider, "Scan Workers" button.
  Widget _buildPreviewState(WorkerMonitorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(controller),
          const SizedBox(height: 24),
          _buildConfidenceSlider(controller),
          const SizedBox(height: 24),
          AppButton(
            text: 'Scan Workers',
            icon: Icons.person_search,
            onPressed: () => controller.scanWorkers(),
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
          if (controller.errorMessage.value.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              controller.errorMessage.value,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Analyzing state - progress indicator, status text.
  Widget _buildAnalyzingState(WorkerMonitorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(controller),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scanning for workers...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Identifying faces and checking PPE compliance',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Obx(
            () => LinearProgressIndicator(
              value: controller.uploadProgress.value,
              backgroundColor: AppColors.cardBackground,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Results state - summary + worker cards with identification badges.
  Widget _buildResultState(WorkerMonitorController controller) {
    final result = controller.detectionResult.value!;

    // Count identified vs unknown
    final identified = result.detections
        .where((d) => d.workerId != null && d.workerId!.isNotEmpty)
        .length;
    final unknown = result.detections.length - identified;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImagePreview(controller),
          const SizedBox(height: 16),
          _buildSummaryHeader(result, identified, unknown),
          const SizedBox(height: 24),
          if (result.detections.isEmpty)
            _buildNoDetectionsMessage()
          else
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
            text: 'New Scan',
            onPressed: () => controller.resetScan(),
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDetectionsMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.person_off, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'No workers detected in the image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try uploading an image with people visible',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  /// Summary header with total detected, identified, unknown, compliant, violations.
  Widget _buildSummaryHeader(
      DetectionResult result, int identified, int unknown) {
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                '${result.detections.length}',
                'Detected',
                Icons.people_outline_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                '$identified',
                'Identified',
                Icons.person_pin_rounded,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem(
                '$unknown',
                'Unknown',
                Icons.person_off_outlined,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
        ],
      ),
    );
  }

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

  /// Worker card with identification badge and PPE status.
  Widget _buildWorkerCard(PersonDetection detection, int workerNumber) {
    final isIdentified =
        detection.workerId != null && detection.workerId!.isNotEmpty;
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
          // Worker header with identification badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isIdentified
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.textSecondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isIdentified ? Icons.person : Icons.person_off,
                  color: isIdentified
                      ? AppColors.success
                      : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIdentified
                          ? detection.workerId!
                          : 'Unknown Worker',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    _buildIdentificationBadge(isIdentified),
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

  /// Green badge for identified, gray for unknown.
  Widget _buildIdentificationBadge(bool isIdentified) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isIdentified
            ? AppColors.success.withOpacity(0.15)
            : AppColors.textSecondary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIdentified ? Icons.verified : Icons.help_outline,
            size: 12,
            color: isIdentified ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            isIdentified ? 'Identified' : 'Not Recognized',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  isIdentified ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Worker compliance status badge.
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
          Icon(_getWorkerStatusIcon(status), color: color, size: 16),
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

  /// PPE item row.
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

  /// Image preview widget.
  Widget _buildImagePreview(WorkerMonitorController controller) {
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

  /// Confidence threshold slider.
  Widget _buildConfidenceSlider(WorkerMonitorController controller) {
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getThresholdColor(
                              controller.confidenceThreshold.value)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(controller.confidenceThreshold.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _getThresholdColor(
                            controller.confidenceThreshold.value),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() {
            final thresholdColor =
                _getThresholdColor(controller.confidenceThreshold.value);
            return SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 20),
                activeTrackColor: thresholdColor,
                inactiveTrackColor: thresholdColor.withOpacity(0.2),
                thumbColor: thresholdColor,
                overlayColor: thresholdColor.withOpacity(0.2),
              ),
              child: Slider(
                value: controller.confidenceThreshold.value,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                label:
                    '${(controller.confidenceThreshold.value * 100).toInt()}%',
                onChanged: (value) {
                  controller.confidenceThreshold.value = value;
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Helper methods ---

  Color _getThresholdColor(double value) {
    if (value < 0.3) return AppColors.warning;
    if (value < 0.6) return AppColors.primary;
    return AppColors.success;
  }

  int _calculateWorkerComplianceScore(PersonDetection detection) {
    if (detection.ppeStatus.isEmpty) return 0;
    final compliant = detection.ppeStatus
        .where((item) => item.status == PPEStatus.compliant)
        .length;
    return ((compliant / detection.ppeStatus.length) * 100).round();
  }

  Color _getWorkerStatusColor(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return AppColors.success;
      case ComplianceStatus.partial:
        return AppColors.warning;
      case ComplianceStatus.nonCompliant:
        return AppColors.error;
      case ComplianceStatus.unknown:
        return AppColors.textSecondary;
    }
  }

  IconData _getWorkerStatusIcon(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return Icons.check_circle;
      case ComplianceStatus.partial:
        return Icons.warning;
      case ComplianceStatus.nonCompliant:
        return Icons.cancel;
      case ComplianceStatus.unknown:
        return Icons.help_outline;
    }
  }

  String _getWorkerStatusLabel(ComplianceStatus status) {
    switch (status) {
      case ComplianceStatus.compliant:
        return 'Compliant';
      case ComplianceStatus.partial:
        return 'Partial';
      case ComplianceStatus.nonCompliant:
        return 'Violation';
      case ComplianceStatus.unknown:
        return 'Unknown';
    }
  }

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

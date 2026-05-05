import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';

import '../controllers/monitoring_controller.dart';
import '../widgets/ppe_indicators/detection_overlay.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/models/detection_result.dart';
import '../../routes/app_routes.dart';

/// Real-time safety monitoring screen with camera feed and PPE detection overlays.
class MonitoringScreen extends GetView<MonitoringController> {
  const MonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        // Show error state if camera is unavailable
        if (!controller.isCameraAvailable.value ||
            controller.cameraError.value.isNotEmpty) {
          return _buildErrorState();
        }

        // Show loading state while camera initializes
        if (!controller.isCameraInitialized.value) {
          return _buildLoadingState();
        }

        // Show main monitoring screen
        return _buildMonitoringScreen(context);
      }),
    );
  }

  /// Builds the main monitoring screen with camera and overlays.
  Widget _buildMonitoringScreen(BuildContext context) {
    return Stack(
      children: [
        // Full-screen camera preview
        _buildCameraPreview(),

        // Top status bar
        _buildTopStatusBar(),

        // Detection overlays
        _buildDetectionOverlays(),

        // Reconnecting indicator
        if (controller.isReconnecting.value) _buildReconnectingIndicator(),

        // Control bar
        _buildControlBar(),

        // Alert banner
        if (controller.showAlert.value) _buildAlertBanner(),
      ],
    );
  }

  /// Builds the camera preview widget.
  Widget _buildCameraPreview() {
    return Positioned.fill(
      child: Obx(() {
        if (controller.cameraController == null ||
            !controller.cameraController!.value.isInitialized) {
          return Container(
            color: AppColors.background,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        return CameraPreview(controller.cameraController!);
      }),
    );
  }

  /// Builds the top status bar with detection counts.
  Widget _buildTopStatusBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  'Detected',
                  controller.detectedCount.value.toString(),
                  AppColors.textPrimary,
                ),
                _buildStatusItem(
                  'Compliant',
                  controller.compliantCount.value.toString(),
                  AppColors.success,
                ),
                _buildStatusItem(
                  'Non-Compliant',
                  controller.nonCompliantCount.value.toString(),
                  AppColors.error,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Builds a single status item for the top bar.
  Widget _buildStatusItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: styles.AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: styles.AppTextStyles.bodyLarge.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Builds the detection overlays for detected persons.
  Widget _buildDetectionOverlays() {
    return Positioned.fill(
      child: Obx(() {
        final detections = controller.detectionResult.detections;
        if (detections.isEmpty) {
          return const SizedBox.shrink();
        }

        // Create a DetectionResult wrapper for each person detection
        final detectionResult = DetectionResult(
          frameId: controller.detectionResult.frameId,
          detected: detections.length,
          compliant: detections
              .where((d) => d.overallStatus == ComplianceStatus.compliant)
              .length,
          nonCompliant: detections
              .where((d) => d.overallStatus == ComplianceStatus.nonCompliant)
              .length,
          detections: detections,
        );

        // Use actual camera frame dimensions so normalized bounding boxes
        // scale correctly. Fall back to screen size until the first frame
        // arrives. TODO: account for preview letterboxing when the preview
        // aspect ratio differs from the frame.
        final screenSize = MediaQuery.of(Get.context!).size;
        final fw = controller.frameWidth.value;
        final fh = controller.frameHeight.value;
        return DetectionOverlay(
          detectionResult: detectionResult,
          imageWidth: fw > 0 ? fw.toDouble() : screenSize.width,
          imageHeight: fh > 0 ? fh.toDouble() : screenSize.height,
        );
      }),
    );
  }

  /// Builds the reconnection indicator.
  Widget _buildReconnectingIndicator() {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reconnecting to detection service...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the control bar with camera toggle and start/stop buttons.
  Widget _buildControlBar() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Camera toggle button
            _buildCameraToggleButton(),

            // Start/Stop button
            _buildStartStopButton(),

            // Settings button
            _buildSettingsButton(),
          ],
        ),
      ),
    );
  }

  /// Builds the camera toggle button.
  Widget _buildCameraToggleButton() {
    return Obx(() {
      return IconButton(
        onPressed: controller.toggleCamera,
        icon: Icon(
          controller.isFrontCamera.value
              ? Icons.camera_rear
              : Icons.camera_front,
          color: AppColors.textPrimary,
          size: 28,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.cardBackground,
          padding: const EdgeInsets.all(12),
        ),
      );
    });
  }

  /// Builds the start/stop monitoring button.
  Widget _buildStartStopButton() {
    return Obx(() {
      final isMonitoring = controller.isMonitoring.value;

      return ElevatedButton.icon(
        onPressed: isMonitoring
            ? controller.stopMonitoring
            : controller.startMonitoring,
        icon: Icon(
          isMonitoring ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
        ),
        label: Text(
          isMonitoring ? 'Stop' : 'Start',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isMonitoring ? AppColors.error : AppColors.success,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  /// Builds the settings button.
  Widget _buildSettingsButton() {
    return IconButton(
      onPressed: () => Get.toNamed(AppRoutes.VIDEO_TEST),
      icon: const Icon(Icons.movie_outlined,
          color: AppColors.textPrimary, size: 28),
      tooltip: 'Test with video',
      style: IconButton.styleFrom(
        backgroundColor: AppColors.cardBackground,
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  /// Builds the alert banner for violations.
  Widget _buildAlertBanner() {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Obx(() {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.alertWorkerId.value != 'Unknown'
                              ? 'Worker ${controller.alertWorkerId.value}'
                              : 'Unknown Worker',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.alertMessage.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: controller.dismissAlert,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
              if (controller.missingPpe.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Missing PPE:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: controller.missingPpe.map((ppe) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        ppe,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  /// Builds the loading state.
  Widget _buildLoadingState() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state.
  Widget _buildErrorState() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Unavailable',
                style: styles.AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                return Text(
                  controller.cameraError.value.isNotEmpty
                      ? controller.cameraError.value
                      : 'Please check camera permissions and try again',
                  style: styles.AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                );
              }),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.VIDEO_TEST),
                icon: const Icon(Icons.movie_outlined, color: Colors.white),
                label: const Text(
                  'Use Video Instead',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardBackground,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

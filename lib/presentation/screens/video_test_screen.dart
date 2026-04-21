import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;
import '../../data/models/detection_result.dart';
import '../controllers/video_test_controller.dart';
import '../widgets/ppe_indicators/detection_overlay.dart';

/// Test harness: runs the detection pipeline against an uploaded video file
/// by extracting frames at ~5 fps and sending them over the same WebSocket
/// the live monitoring screen uses.
class VideoTestScreen extends GetView<VideoTestController> {
  const VideoTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Video Detection Test'),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.videoFile.value == null) {
            return _buildEmptyState();
          }
          return _buildRunnerState(context);
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.movie_outlined,
                size: 72, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'Pick a video to test PPE detection',
              style: styles.AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Frames are extracted at ~5 fps and sent to the detection server.',
              style: styles.AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.pickVideo,
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick Video from Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
            Obx(() {
              final err = controller.errorMessage.value;
              if (err.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(err,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRunnerState(BuildContext context) {
    return Column(
      children: [
        _buildStatusBar(),
        Expanded(child: _buildFramePreview(context)),
        _buildProgressRow(),
        _buildControls(),
        Obx(() {
          final err = controller.errorMessage.value;
          if (err.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              err,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statusItem('Detected', '${controller.detectedCount.value}',
                AppColors.textPrimary),
            _statusItem('Compliant', '${controller.compliantCount.value}',
                AppColors.success),
            _statusItem('Violations',
                '${controller.nonCompliantCount.value}', AppColors.error),
          ],
        );
      }),
    );
  }

  Widget _statusItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: styles.AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style: styles.AppTextStyles.bodyLarge
                .copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFramePreview(BuildContext context) {
    return Obx(() {
      final frame = controller.currentFrame.value;
      final fw = controller.frameWidth.value;
      final fh = controller.frameHeight.value;

      if (frame == null) {
        return Center(
          child: Text(
            controller.isRunning.value ? 'Extracting frames…' : 'Ready',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        );
      }

      final detections = controller.currentDetection.value.detections;
      final result = DetectionResult(
        frameId: controller.currentDetection.value.frameId,
        detected: detections.length,
        compliant: detections
            .where((d) => d.overallStatus == ComplianceStatus.compliant)
            .length,
        nonCompliant: detections
            .where((d) => d.overallStatus == ComplianceStatus.nonCompliant)
            .length,
        detections: detections,
      );

      final size = MediaQuery.of(context).size;
      final imgW = fw > 0 ? fw.toDouble() : size.width;
      final imgH = fh > 0 ? fh.toDouble() : size.height;

      return LayoutBuilder(
        builder: (ctx, constraints) {
          return Center(
            child: AspectRatio(
              aspectRatio: imgW / imgH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(frame, gaplessPlayback: true,
                      fit: BoxFit.contain),
                  Positioned.fill(
                    child: DetectionOverlay(
                      detectionResult: result,
                      imageWidth: imgW,
                      imageHeight: imgH,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildProgressRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() {
        final pos = controller.currentPositionMs.value;
        final total = controller.videoDurationMs.value;
        final progress = total > 0 ? (pos / total).clamp(0.0, 1.0) : 0.0;
        return Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.cardBackground,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              '${controller.formatMs(pos)} / ${controller.formatMs(total)}'
              '${controller.isWebSocketConnected.value ? ' · connected' : ''}',
              style: styles.AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() {
        final running = controller.isRunning.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            OutlinedButton.icon(
              onPressed: running ? null : controller.pickVideo,
              icon: const Icon(Icons.movie),
              label: const Text('Change Video'),
            ),
            ElevatedButton.icon(
              onPressed: running ? controller.stop : controller.start,
              icon: Icon(running ? Icons.stop : Icons.play_arrow),
              label: Text(running ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    running ? AppColors.error : AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        );
      }),
    );
  }
}

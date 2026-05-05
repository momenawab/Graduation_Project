import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

import '../../data/models/detection_result.dart';
import '../../data/services/websocket/detection_stream.dart';

/// Runs the existing WebSocket detection pipeline against a picked video file.
/// Extracts frames at ~5 fps with video_thumbnail, sends each as JPEG bytes
/// via [DetectionStream], and exposes the current frame + detection results
/// so a screen can render the same overlay as the live camera flow.
class VideoTestController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  DetectionStream? _detectionStream;
  StreamSubscription<DetectionResult>? _detectionSubscription;

  // Video state
  Rxn<File> videoFile = Rxn<File>();
  RxInt videoDurationMs = 0.obs;
  RxInt frameWidth = 0.obs;
  RxInt frameHeight = 0.obs;

  // Playback state
  RxBool isRunning = false.obs;
  RxBool isConnecting = false.obs;
  RxBool isWebSocketConnected = false.obs;
  RxString errorMessage = ''.obs;
  RxInt currentPositionMs = 0.obs;
  final Rxn<Uint8List> currentFrame = Rxn<Uint8List>();

  // Detection state (mirrors MonitoringController shape)
  Rx<DetectionResult> currentDetection = DetectionResult(
    frameId: '',
    detected: 0,
    compliant: 0,
    nonCompliant: 0,
    detections: [],
  ).obs;
  RxInt detectedCount = 0.obs;
  RxInt compliantCount = 0.obs;
  RxInt nonCompliantCount = 0.obs;

  static const int _targetFps = 5;
  static const int _stepMs = 1000 ~/ _targetFps;

  bool _abort = false;

  // How many consecutive empty frames before clearing the last detection
  static const int _emptyFramesToClear = 10;
  int _emptyFrameCount = 0;

  @override
  void onClose() {
    _abort = true;
    _detectionSubscription?.cancel();
    _detectionStream?.disconnect();
    super.onClose();
  }

  Future<void> pickVideo() async {
    try {
      final picked = await _picker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);
      videoFile.value = file;
      currentFrame.value = null;
      currentPositionMs.value = 0;
      errorMessage.value = '';

      // Probe duration & dimensions with video_player.
      final probe = VideoPlayerController.file(file);
      try {
        await probe.initialize();
        videoDurationMs.value = probe.value.duration.inMilliseconds;
        frameWidth.value = probe.value.size.width.toInt();
        frameHeight.value = probe.value.size.height.toInt();
      } finally {
        await probe.dispose();
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick video: $e';
    }
  }

  Future<void> start() async {
    final file = videoFile.value;
    if (file == null || isRunning.value) return;
    if (videoDurationMs.value <= 0) {
      errorMessage.value = 'Video duration unknown';
      return;
    }

    _abort = false;
    isRunning.value = true;
    isConnecting.value = true;
    errorMessage.value = '';

    try {
      _detectionStream = DetectionStream();
      await _detectionStream!.connect();
      isWebSocketConnected.value = true;
      isConnecting.value = false;

      _detectionStream!.sendConfig(
        requiredPPE: ['hardHat', 'vest', 'gloves', 'steelToedBoots'],
        confidenceThreshold: 0.5,
      );

      _detectionSubscription =
          _detectionStream!.detectionStream.listen(_handleDetectionResult);

      await _runFrameLoop(file);
    } catch (e) {
      errorMessage.value = 'Failed to start: $e';
    } finally {
      isRunning.value = false;
      isConnecting.value = false;
      isWebSocketConnected.value = false;
      await _detectionSubscription?.cancel();
      _detectionSubscription = null;
      await _detectionStream?.disconnect();
      _detectionStream = null;
    }
  }

  Future<void> stop() async {
    _abort = true;
  }

  Future<void> _runFrameLoop(File file) async {
    final durationMs = videoDurationMs.value;

    for (int t = 0; t < durationMs && !_abort; t += _stepMs) {
      final sw = Stopwatch()..start();

      try {
        final bytes = await vt.VideoThumbnail.thumbnailData(
          video: file.path,
          imageFormat: vt.ImageFormat.JPEG,
          timeMs: t,
          quality: 75,
          maxWidth: 1280,
        );

        if (bytes != null && bytes.isNotEmpty) {
          currentFrame.value = bytes;
          currentPositionMs.value = t;
          _detectionStream?.sendFrameBytes(bytes);
        }
      } catch (e) {
        errorMessage.value = 'Frame extract failed at ${t}ms: $e';
      }

      // Pace the loop so we don't blast the socket.
      final elapsed = sw.elapsedMilliseconds;
      if (elapsed < _stepMs) {
        await Future.delayed(Duration(milliseconds: _stepMs - elapsed));
      }
    }
  }

  void _handleDetectionResult(DetectionResult result) {
    if (result.detected > 0) {
      // New detection — update everything and reset empty counter
      _emptyFrameCount = 0;
      currentDetection.value = result;
      detectedCount.value = result.detected;
      compliantCount.value = result.compliant;
      nonCompliantCount.value = result.nonCompliant;
    } else {
      // Empty frame — only clear after enough consecutive empty frames
      _emptyFrameCount++;
      if (_emptyFrameCount >= _emptyFramesToClear) {
        currentDetection.value = result;
        detectedCount.value = 0;
        compliantCount.value = 0;
        nonCompliantCount.value = 0;
      }
    }
  }

  String formatMs(int ms) {
    final totalSeconds = ms ~/ 1000;
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  List<PersonDetection> get detections => currentDetection.value.detections;
}

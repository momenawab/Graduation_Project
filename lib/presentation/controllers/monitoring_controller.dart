import 'dart:async';
import 'dart:io' show Platform;
import 'package:camera/camera.dart';
import 'package:get/get.dart';

import '../../core/utils/camera_image_converter.dart';
import '../../data/models/detection_result.dart';
import '../../data/models/ppe_item.dart';
import '../../data/services/websocket/detection_stream.dart';

/// Controller for real-time safety monitoring screen.
/// Manages camera lifecycle, detection stream, and alert state.
class MonitoringController extends GetxController {
  // Camera state
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  RxBool isCameraInitialized = false.obs;
  RxBool isCameraAvailable = false.obs;
  RxBool isMonitoring = false.obs;
  RxBool isFrontCamera = false.obs;
  RxString cameraError = ''.obs;

  // Detection stream state
  DetectionStream? _detectionStream;
  StreamSubscription<DetectionResult>? _detectionSubscription;
  Rx<DetectionResult> currentDetection = DetectionResult(
    frameId: '',
    detected: 0,
    compliant: 0,
    nonCompliant: 0,
    detections: [],
  ).obs;

  // Detection counts for status bar
  RxInt detectedCount = 0.obs;
  RxInt compliantCount = 0.obs;
  RxInt nonCompliantCount = 0.obs;

  // Alert state
  RxBool showAlert = false.obs;
  RxString alertMessage = ''.obs;
  RxString alertWorkerId = ''.obs;
  RxList<String> missingPpe = <String>[].obs;

  // Timer state
  Timer? _monitoringTimer;
  RxInt monitoringSeconds = 0.obs;

  // WebSocket connection state
  RxBool isWebSocketConnected = false.obs;
  RxBool isReconnecting = false.obs;

  // Frame streaming state
  static const int _targetFps = 5;
  bool _isSending = false;
  bool _isStreamingFrames = false;
  DateTime _lastSentAt = DateTime.fromMillisecondsSinceEpoch(0);
  RxInt frameWidth = 0.obs;
  RxInt frameHeight = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  @override
  void onClose() {
    _cleanup();
    super.onClose();
  }

  /// Initializes the camera and prepares for monitoring.
  Future<void> _initializeCamera() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        cameraError.value = 'No cameras available';
        isCameraAvailable.value = false;
        return;
      }

      isCameraAvailable.value = true;

      // Initialize the back camera by default
      await _initCameraController(_cameras.first);
    } catch (e) {
      cameraError.value = 'Camera initialization failed: ${e.toString()}';
      isCameraAvailable.value = false;
    }
  }

  /// Initializes a camera controller with the specified camera description.
  Future<void> _initCameraController(CameraDescription camera) async {
    try {
      await _disposeCameraController();

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.yuv420
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      isCameraInitialized.value = true;
      cameraError.value = '';
    } catch (e) {
      cameraError.value = 'Failed to initialize camera: ${e.toString()}';
      isCameraInitialized.value = false;
    }
  }

  /// Disposes the current camera controller.
  Future<void> _disposeCameraController() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      await _stopFrameStream();
      await _cameraController!.dispose();
      _cameraController = null;
      isCameraInitialized.value = false;
    }
  }

  /// Toggles between front and back camera.
  Future<void> toggleCamera() async {
    if (_cameras.length < 2) return;

    isFrontCamera.value = !isFrontCamera.value;
    final camera = isFrontCamera.value
        ? _cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras.first,
          )
        : _cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras.first,
          );

    await _initCameraController(camera);
  }

  /// Starts the monitoring session with camera and detection stream.
  Future<void> startMonitoring() async {
    if (!isCameraAvailable.value || !isCameraInitialized.value) {
      cameraError.value = 'Camera not available';
      return;
    }

    if (isMonitoring.value) return;

    try {
      isMonitoring.value = true;
      monitoringSeconds.value = 0;

      // Start monitoring timer
      _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        monitoringSeconds.value++;
      });

      // Connect to detection stream
      await _connectDetectionStream();

      // Begin capturing and sending camera frames
      await _startFrameStream();
    } catch (e) {
      cameraError.value = 'Failed to start monitoring: ${e.toString()}';
      isMonitoring.value = false;
    }
  }

  /// Stops the monitoring session.
  Future<void> stopMonitoring() async {
    if (!isMonitoring.value) return;

    isMonitoring.value = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;

    await _stopFrameStream();
    await _disconnectDetectionStream();
  }

  /// Starts the camera image stream and forwards frames to the detection socket.
  Future<void> _startFrameStream() async {
    final cam = _cameraController;
    if (cam == null || !cam.value.isInitialized || _isStreamingFrames) return;

    try {
      await cam.startImageStream(_onCameraImage);
      _isStreamingFrames = true;
    } catch (e) {
      cameraError.value = 'Failed to start image stream: $e';
    }
  }

  /// Stops the camera image stream if running.
  Future<void> _stopFrameStream() async {
    final cam = _cameraController;
    if (cam == null || !_isStreamingFrames) return;

    try {
      if (cam.value.isStreamingImages) {
        await cam.stopImageStream();
      }
    } catch (_) {
      // Best-effort: camera may already be disposing.
    } finally {
      _isStreamingFrames = false;
      _isSending = false;
    }
  }

  /// Handles each camera frame: throttled, backpressured encode + send.
  void _onCameraImage(CameraImage image) {
    if (frameWidth.value == 0) {
      frameWidth.value = image.width;
      frameHeight.value = image.height;
    }

    if (_isSending) return;
    if (!isWebSocketConnected.value) return;

    final now = DateTime.now();
    final minGap = Duration(milliseconds: 1000 ~/ _targetFps);
    if (now.difference(_lastSentAt) < minGap) return;

    _isSending = true;
    _lastSentAt = now;

    try {
      // The camera stream is in the sensor's native orientation, which is
      // sideways when the phone is held in portrait. Rotate it upright so the
      // detection model (and worker face matching) sees a normal scene.
      // copyRotate() in the image package rotates clockwise. Verified against a
      // real device frame: the back-camera stream needs a 270° (i.e. 90° CCW)
      // turn to stand the subject upright; the mirrored front camera needs 90°.
      final desc = _cameraController?.description;
      final sensor = desc?.sensorOrientation ?? 90;
      int rotation = (360 - sensor) % 360; // back camera
      if (desc?.lensDirection == CameraLensDirection.front) {
        rotation = sensor % 360;
      }
      final bytes = CameraImageConverter.cameraImageToJpeg(
        image,
        rotationDegrees: rotation,
      );
      if (bytes != null && _detectionStream != null) {
        _detectionStream!.sendFrameBytes(bytes);
      }
    } catch (e) {
      // Transient encode/send failures shouldn't tear down the session.
      cameraError.value = 'Frame encode failed: $e';
    } finally {
      _isSending = false;
    }
  }

  /// Connects to the WebSocket detection stream.
  Future<void> _connectDetectionStream() async {
    try {
      // Use WebSocket URL from API constants
      _detectionStream = DetectionStream();  // Uses default URL from ApiConstants
      await _detectionStream!.connect();

      isWebSocketConnected.value = true;
      isReconnecting.value = false;

      // Send initial configuration
      _detectionStream!.sendConfig(
        requiredPPE: ['hardHat', 'vest', 'gloves', 'steelToedBoots'],
        confidenceThreshold: 0.5,
      );

      // Subscribe to detection results
      _detectionSubscription = _detectionStream!.detectionStream.listen(
        _handleDetectionResult,
        onError: _handleDetectionError,
        onDone: _handleDetectionDone,
      );
    } catch (e) {
      isWebSocketConnected.value = false;
      cameraError.value =
          'Failed to connect to detection stream: ${e.toString()}';
    }
  }

  /// Disconnects from the WebSocket detection stream.
  Future<void> _disconnectDetectionStream() async {
    _detectionSubscription?.cancel();
    _detectionSubscription = null;

    await _detectionStream?.disconnect();
    _detectionStream = null;

    isWebSocketConnected.value = false;
  }

  /// Handles incoming detection results from the stream.
  void _handleDetectionResult(DetectionResult result) {
    // Update current detection
    currentDetection.value = result;

    // Update counts
    detectedCount.value = result.detected;
    compliantCount.value = result.compliant;
    nonCompliantCount.value = result.nonCompliant;

    // Check for violations and show alert
    _checkForViolations(result);
  }

  /// Handles errors from the detection stream.
  void _handleDetectionError(dynamic error) {
    isWebSocketConnected.value = false;
    cameraError.value = 'Detection stream error: ${error.toString()}';

    // Attempt to reconnect
    _attemptReconnect();
  }

  /// Handles when the detection stream closes.
  void _handleDetectionDone() {
    isWebSocketConnected.value = false;

    // Attempt to reconnect if still monitoring
    if (isMonitoring.value) {
      _attemptReconnect();
    }
  }

  /// Attempts to reconnect to the detection stream.
  Future<void> _attemptReconnect() async {
    if (isReconnecting.value) return;

    isReconnecting.value = true;

    // Wait before reconnecting
    await Future.delayed(const Duration(seconds: 3));

    if (isMonitoring.value) {
      await _connectDetectionStream();
    } else {
      isReconnecting.value = false;
    }
  }

  /// Checks detection results for violations and shows alert if found.
  void _checkForViolations(DetectionResult result) {
    if (result.nonCompliant > 0) {
      // Find the first non-compliant detection
      final violation = result.detections.firstWhere(
        (d) => d.overallStatus == ComplianceStatus.nonCompliant,
        orElse: () => result.detections.first,
      );

      // Get missing PPE items
      final missingItems = violation.ppeStatus
          .where(
            (item) =>
                item.status == PPEStatus.missing ||
                item.status == PPEStatus.notSuitable,
          )
          .map((item) => item.type.name)
          .toList();

      if (missingItems.isNotEmpty) {
        showAlert.value = true;
        alertWorkerId.value = violation.workerId ?? 'Unknown';
        alertMessage.value = 'PPE violation detected';
        missingPpe.value = missingItems;
      }
    } else {
      showAlert.value = false;
      alertMessage.value = '';
      alertWorkerId.value = '';
      missingPpe.clear();
    }
  }

  /// Dismisses the current alert.
  void dismissAlert() {
    showAlert.value = false;
    alertMessage.value = '';
    alertWorkerId.value = '';
    missingPpe.clear();
  }

  /// Cleans up resources when the controller is closed.
  void _cleanup() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _detectionSubscription?.cancel();
    _detectionSubscription = null;
    _stopFrameStream();
    _disposeCameraController();
    _disconnectDetectionStream();
  }

  /// Formats monitoring time as MM:SS.
  String get formattedTime {
    final minutes = monitoringSeconds.value ~/ 60;
    final seconds = monitoringSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Gets the current camera controller.
  CameraController? get cameraController => _cameraController;

  /// Gets the current detection result.
  DetectionResult get detectionResult => currentDetection.value;
}

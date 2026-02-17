import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/detection_result.dart';
import '../../data/services/api/detection_api_service.dart';

/// Controller for Workers Monitor feature.
/// Reuses DetectionApiService to upload images for face recognition + PPE detection.
class WorkerMonitorController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  late final DetectionApiService _detectionApi;

  /// Currently selected image file
  final Rx<File?> selectedImage = Rx<File?>(null);

  /// Whether analysis is in progress
  final RxBool isAnalyzing = false.obs;

  /// Detection result from backend
  final Rx<DetectionResult?> detectionResult = Rx<DetectionResult?>(null);

  /// Upload progress (0.0 to 1.0)
  final RxDouble uploadProgress = 0.0.obs;

  /// Whether an image has been selected
  final RxBool hasImage = false.obs;

  /// Error message if any
  final RxString errorMessage = ''.obs;

  /// Confidence threshold for detection (0.0 to 1.0)
  final RxDouble confidenceThreshold = 0.5.obs;

  /// Connection status
  final RxBool isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    _detectionApi = DetectionApiService();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    isConnected.value = await _detectionApi.checkHealth();
  }

  /// Select image from camera.
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        hasImage.value = true;
        detectionResult.value = null;
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
    }
  }

  /// Select image from gallery.
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        hasImage.value = true;
        detectionResult.value = null;
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to select image: $e';
    }
  }

  /// Scan workers in the selected image.
  /// Uses the same detection/upload endpoint which does face recognition + PPE detection.
  Future<void> scanWorkers() async {
    if (selectedImage.value == null) {
      errorMessage.value = 'Please select an image first';
      return;
    }

    isAnalyzing.value = true;
    uploadProgress.value = 0.0;
    errorMessage.value = '';

    try {
      final healthOk = await _detectionApi.checkHealth();
      if (!healthOk) {
        errorMessage.value =
            'Backend is not reachable. Please check your connection.';
        isAnalyzing.value = false;
        return;
      }

      uploadProgress.value = 0.3;

      final result = await _detectionApi.uploadImageForDetection(
        selectedImage.value!,
        confidenceThreshold: confidenceThreshold.value,
      );

      uploadProgress.value = 0.8;
      detectionResult.value = result;
      uploadProgress.value = 1.0;
    } catch (e) {
      errorMessage.value = 'Scan failed: $e';

      if (e.toString().contains('Cannot connect to server')) {
        errorMessage.value = 'Cannot connect to backend. Server may be down.';
      } else if (e.toString().contains('timeout')) {
        errorMessage.value =
            'Request timeout. Check your internet connection.';
      }
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Reset the scan state.
  void resetScan() {
    selectedImage.value = null;
    hasImage.value = false;
    uploadProgress.value = 0.0;
    detectionResult.value = null;
    isAnalyzing.value = false;
    errorMessage.value = '';
  }

}

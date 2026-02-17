import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safesight/core/constants/api_constants.dart';
import '../../data/models/ppe_item.dart';
import '../../data/models/upload_result.dart';
import '../../data/models/detection_result.dart';
import '../../data/services/api/detection_api_service.dart';

/// Controller for managing image upload and PPE analysis functionality.
class UploadController extends GetxController {
  /// Image picker instance
  final ImagePicker _picker = ImagePicker();

  /// Detection API service
  late final DetectionApiService _detectionApi;

  /// Currently selected image file
  final Rx<File?> selectedImage = Rx<File?>(null);

  /// Upload progress (0.0 to 1.0)
  final RxDouble uploadProgress = 0.0.obs;

  /// Analysis result observable
  final Rx<UploadDetectionResult?> analysisResult = Rx<UploadDetectionResult?>(
    null,
  );

  /// Detection result from backend
  final Rx<DetectionResult?> detectionResult = Rx<DetectionResult?>(null);

  /// Whether analysis is in progress
  final RxBool isAnalyzing = false.obs;

  /// Whether an image has been selected
  final RxBool hasImage = false.obs;

  /// Error message if any
  final RxString errorMessage = ''.obs;

  /// Connection status
  final RxBool isConnected = false.obs;

  /// Confidence threshold for PPE detection (0.0 to 1.0)
  final RxDouble confidenceThreshold = 0.5.obs;

  @override
  void onInit() {
    super.onInit();
    _detectionApi = DetectionApiService();
    _checkConnection();
  }

  /// Check backend connection
  Future<void> _checkConnection() async {
    isConnected.value = await _detectionApi.checkHealth();
  }

  /// Select image from camera
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
        analysisResult.value = null;
        detectionResult.value = null;
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to capture image: $e';
    }
  }

  /// Select image from gallery
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
        analysisResult.value = null;
        detectionResult.value = null;
        errorMessage.value = '';
      }
    } catch (e) {
      errorMessage.value = 'Failed to select image: $e';
    }
  }

  /// Scan/analyze the selected image for PPE compliance
  Future<void> scanImage() async {
    if (selectedImage.value == null) {
      errorMessage.value = 'Please select an image first';
      return;
    }

    isAnalyzing.value = true;
    uploadProgress.value = 0.0;
    errorMessage.value = '';

    try {
      // Debug log
      print('🔵 [DEBUG] Starting image scan...');
      print('🔵 [DEBUG] Image path: ${selectedImage.value?.path}');
      print('🔵 [DEBUG] Image exists: ${selectedImage.value?.existsSync()}');
      print('🔵 [DEBUG] API URL: ${ApiConstants.baseUrl}');

      // Check connection first
      final healthOk = await _detectionApi.checkHealth();
      print('🔵 [DEBUG] Health check: $healthOk');

      if (!healthOk) {
        errorMessage.value = 'Backend is not reachable. Please check your connection.';
        isAnalyzing.value = false;
        return;
      }

      // Upload and analyze
      uploadProgress.value = 0.3;
      print('🔵 [DEBUG] Uploading image...');

      final result = await _detectionApi.uploadImageForDetection(
        selectedImage.value!,
        confidenceThreshold: confidenceThreshold.value,
      );

      uploadProgress.value = 0.8;
      detectionResult.value = result;
      print('🔵 [DEBUG] Upload successful! Detections: ${result.detections.length}');

      // Convert DetectionResult to UploadDetectionResult format
      final uploadResult = _convertToUploadResult(result);
      analysisResult.value = uploadResult;

      uploadProgress.value = 1.0;
      print('🟢 [DEBUG] Analysis completed successfully');
    } catch (e) {
      print('🔴 [ERROR] Analysis failed: $e');
      print('🔴 [ERROR] Error type: ${e.runtimeType}');
      errorMessage.value = 'Analysis failed: $e';

      // Show detailed error info
      if (e.toString().contains('Cannot connect to server')) {
        errorMessage.value = 'Cannot connect to backend. Server may be down.';
      } else if (e.toString().contains('Connection refused')) {
        errorMessage.value = 'Connection refused. Check server URL and port.';
      } else if (e.toString().contains('timeout')) {
        errorMessage.value = 'Request timeout. Check your internet connection.';
      } else if (e.toString().contains('404')) {
        errorMessage.value = 'API endpoint not found. Check server configuration.';
      } else if (e.toString().contains('500')) {
        errorMessage.value = 'Server error. Contact support.';
      }
    } finally {
      isAnalyzing.value = false;
    }
  }

  /// Convert DetectionResult to UploadDetectionResult
  UploadDetectionResult _convertToUploadResult(DetectionResult result) {
    // Collect all PPE items from all detections
    final allPPEItems = <PPEItem>[];

    for (final detection in result.detections) {
      allPPEItems.addAll(detection.ppeStatus);
    }

    // Calculate compliance score
    final totalPPE = allPPEItems.length;
    final compliantPPE = allPPEItems
        .where((item) => item.status == PPEStatus.compliant)
        .length;

    final complianceScore = totalPPE > 0
        ? ((compliantPPE / totalPPE) * 100).round()
        : 0;

    return UploadDetectionResult(
      imageId: result.frameId,
      imageUrl: selectedImage.value?.path ?? '',
      analysisStatus: AnalysisStatus.completed,
      complianceScore: complianceScore,
      ppeResults: allPPEItems,
      analyzedAt: DateTime.now(),
      detectedCount: result.detected,
      compliantCount: result.compliant,
      nonCompliantCount: result.nonCompliant,
    );
  }

  /// Reset the upload state for a new scan
  void resetScan() {
    selectedImage.value = null;
    hasImage.value = false;
    uploadProgress.value = 0.0;
    analysisResult.value = null;
    detectionResult.value = null;
    isAnalyzing.value = false;
    errorMessage.value = '';
  }

  /// Retry connection check
  Future<void> retryConnection() async {
    await _checkConnection();
    if (!isConnected.value) {
      errorMessage.value = 'Backend not reachable. Check if server is running.';
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

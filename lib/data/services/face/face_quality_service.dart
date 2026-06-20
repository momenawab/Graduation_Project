import 'dart:io';
import 'dart:ui' as ui;

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// The angle a guided enrollment shot should capture.
enum FaceAngle { front, left, right }

extension FaceAngleLabel on FaceAngle {
  String get label {
    switch (this) {
      case FaceAngle.front:
        return 'Front';
      case FaceAngle.left:
        return 'Left';
      case FaceAngle.right:
        return 'Right';
    }
  }

  String get hint {
    switch (this) {
      case FaceAngle.front:
        return 'Look straight at the camera';
      case FaceAngle.left:
        return 'Turn your head to the left';
      case FaceAngle.right:
        return 'Turn your head to the right';
    }
  }
}

/// Result of an on-device face quality check.
class FaceQualityResult {
  final bool ok;
  final String message;
  const FaceQualityResult(this.ok, this.message);
}

/// On-device face quality gate used during worker enrollment.
///
/// Runs Google ML Kit face detection on a captured still and verifies it is
/// usable (exactly one face, large enough, eyes open, and at the expected
/// angle) before it is uploaded to the backend for embedding. This keeps
/// low-quality photos from ever reaching the recognition model.
class FaceQualityService {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true, // eye-open probabilities
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.1,
    ),
  );

  // A detected face must span at least this fraction of the image width.
  static const double _minFaceWidthRatio = 0.15;
  // Eyes must be open above this probability.
  static const double _minEyeOpen = 0.4;
  // Yaw thresholds (degrees) separating "front" from a clear side turn.
  static const double _frontMaxYaw = 14;
  static const double _sideMinYaw = 12;

  /// Analyze [file] for the given [angle]. Returns whether it is acceptable
  /// and a user-facing message describing any problem.
  Future<FaceQualityResult> analyze(File file, FaceAngle angle) async {
    List<Face> faces;
    try {
      final input = InputImage.fromFilePath(file.path);
      faces = await _detector.processImage(input);
    } catch (_) {
      return const FaceQualityResult(false, 'Could not analyze the photo. Try again.');
    }

    if (faces.isEmpty) {
      return const FaceQualityResult(
          false, 'No face detected. Center your face in the frame.');
    }
    if (faces.length > 1) {
      return const FaceQualityResult(
          false, 'Multiple faces detected. Only one person should be visible.');
    }

    final face = faces.first;

    // Face must be large enough relative to the image.
    final imageWidth = await _imageWidth(file);
    if (imageWidth != null && imageWidth > 0) {
      final ratio = face.boundingBox.width / imageWidth;
      if (ratio < _minFaceWidthRatio) {
        return const FaceQualityResult(
            false, 'Face is too small. Move closer to the camera.');
      }
    }

    // Both eyes should be open.
    final left = face.leftEyeOpenProbability;
    final right = face.rightEyeOpenProbability;
    if (left != null && right != null &&
        (left < _minEyeOpen || right < _minEyeOpen)) {
      return const FaceQualityResult(false, 'Keep both eyes open.');
    }

    // Angle check based on yaw (rotation about the vertical axis).
    final yaw = face.headEulerAngleY ?? 0;
    if (angle == FaceAngle.front) {
      if (yaw.abs() > _frontMaxYaw) {
        return const FaceQualityResult(
            false, 'Look straight at the camera for the front photo.');
      }
    } else {
      if (yaw.abs() < _sideMinYaw) {
        return FaceQualityResult(
            false, 'Turn your head further to the ${angle.label.toLowerCase()}.');
      }
    }

    return const FaceQualityResult(true, '');
  }

  Future<double?> _imageWidth(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image.width.toDouble();
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _detector.close();
  }
}

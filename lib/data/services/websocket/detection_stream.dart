import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:safesight/core/constants/api_constants.dart';
import '../../models/detection_result.dart';
import '../../models/ppe_item.dart';
import 'stream_client.dart';

/// Detection Stream WebSocket service for real-time PPE detection.
///
/// Manages WebSocket connection for receiving detection results
/// and provides reconnection logic for connection failures.
class DetectionStream {
  /// The WebSocket client instance
  StreamClient? _client;

  /// Stream controller for detection results
  final StreamController<DetectionResult> _detectionController =
      StreamController<DetectionResult>.broadcast();

  /// Stream of detection results
  Stream<DetectionResult> get detectionStream => _detectionController.stream;

  /// Observable connection state (for GetX)
  final RxBool isConnected = false.obs;

  /// Observable error state (for GetX)
  final RxString errorMessage = ''.obs;

  /// WebSocket URL
  final String wsUrl;

  /// Reconnection delay
  static const Duration reconnectionDelay = Duration(seconds: 3);

  /// Maximum reconnection attempts
  static const int maxReconnectionAttempts = 5;

  /// Current reconnection attempt count
  int _reconnectionAttempts = 0;

  /// Creates a new DetectionStream instance.
  DetectionStream({String? wsUrl}) : wsUrl = wsUrl ?? '${ApiConstants.wsUrl}${ApiConstants.wsDetection}';

  /// Connects to the WebSocket server.
  Future<void> connect() async {
    try {
      _client = StreamClient.connect(wsUrl);
      isConnected.value = true;
      errorMessage.value = '';
      _reconnectionAttempts = 0;

      // Listen for incoming messages
      _client!.stream.listen(
        (dynamic message) {
          try {
            // Handle both String and bytes messages
            Map<String, dynamic> jsonData;

            if (message is String) {
              jsonData = json.decode(message) as Map<String, dynamic>;
            } else if (message is List<int>) {
              // Binary data received (shouldn't happen for responses)
              final jsonString = utf8.decode(message as List<int>);
              jsonData = json.decode(jsonString) as Map<String, dynamic>;
            } else {
              jsonData = message as Map<String, dynamic>;
            }

            // Parse based on message type
            if (jsonData['type'] == 'detection' || jsonData['frame_id'] != null) {
              final detectionResult = _parseDetectionResult(jsonData);
              _detectionController.add(detectionResult);
            } else if (jsonData['type'] == 'connected') {
              // Connection acknowledgment
              print('WebSocket connected: ${jsonData['message']}');
            } else if (jsonData['type'] == 'error') {
              errorMessage.value = 'Server error: ${jsonData['message']}';
            }
          } catch (e) {
            errorMessage.value = 'Failed to parse detection result: $e';
          }
        },
        onError: (error) {
          errorMessage.value = 'WebSocket error: $error';
          _handleDisconnection();
        },
        onDone: () {
          _handleDisconnection();
        },
      );
    } catch (e) {
      errorMessage.value = 'Failed to connect: $e';
      isConnected.value = false;
      _scheduleReconnection();
    }
  }

  /// Send an image frame for detection.
  ///
  /// Converts the image to JPEG bytes and sends to server.
  Future<void> sendFrame(img.Image image) async {
    if (_client == null || _client!.isClosed) {
      errorMessage.value = 'Not connected to server';
      return;
    }

    try {
      // Encode image to JPEG
      final jpegBytes = img.encodeJpg(image);

      // Send binary data
      _client!.send(jpegBytes);
    } catch (e) {
      errorMessage.value = 'Failed to send frame: $e';
    }
  }

  /// Send image bytes directly.
  void sendFrameBytes(Uint8List bytes) {
    if (_client == null || _client!.isClosed) {
      errorMessage.value = 'Not connected to server';
      return;
    }

    try {
      _client!.send(bytes);
    } catch (e) {
      errorMessage.value = 'Failed to send frame: $e';
    }
  }

  /// Send configuration message to server.
  void sendConfig({
    List<String>? requiredPPE,
    double? confidenceThreshold,
  }) {
    if (_client == null || _client!.isClosed) {
      return;
    }

    final config = {
      'type': 'config',
      if (requiredPPE != null) 'required_ppe': requiredPPE,
      if (confidenceThreshold != null) 'confidence_threshold': confidenceThreshold,
    };

    _client!.send(json.encode(config));
  }

  /// Parse detection result from backend response.
  DetectionResult _parseDetectionResult(Map<String, dynamic> jsonData) {
    final detectionsList = jsonData['detections'] as List? ?? [];

    final detections = detectionsList.map((d) {
      final detection = d as Map<String, dynamic>;
      final ppeStatusList = detection['ppeStatus'] as List? ?? [];

      return PersonDetection(
        workerId: detection['workerId'] as String?,
        boundingBox: BoundingBox.fromJson(
          detection['boundingBox'] as Map<String, dynamic>,
        ),
        ppeStatus: ppeStatusList.map((ppe) {
          final item = ppe as Map<String, dynamic>;
          return PPEItem(
            type: _parsePPEType(item['type'] as String),
            status: _parsePPEStatus(item['status'] as String),
            lastDetected: item['lastDetected'] != null
                ? DateTime.tryParse(item['lastDetected'] as String)
                : null,
          );
        }).toList(),
        overallStatus: _parseOverallStatus(
          detection['overallStatus'] as String? ?? 'unknown',
        ),
        confidence: (detection['confidence'] as num).toDouble(),
      );
    }).toList();

    return DetectionResult(
      frameId: jsonData['frame_id'] as String? ?? jsonData['frameId'] as String? ?? '',
      detected: jsonData['detected'] as int? ?? 0,
      compliant: jsonData['compliant'] as int? ?? 0,
      nonCompliant: jsonData['non_compliant'] as int? ??
                   jsonData['nonCompliant'] as int? ?? 0,
      detections: detections,
    );
  }

  PPEType _parsePPEType(String type) {
    switch (type.toLowerCase()) {
      case 'hardhat':
        return PPEType.hardHat;
      case 'safetyglasses':
        return PPEType.safetyGlasses;
      case 'vest':
        return PPEType.vest;
      case 'gloves':
        return PPEType.gloves;
      case 'steeltoedboots':
        return PPEType.steelToedBoots;
      case 'earprotection':
        return PPEType.earProtection;
      default:
        return PPEType.hardHat;
    }
  }

  PPEStatus _parsePPEStatus(String status) {
    switch (status.toLowerCase()) {
      case 'compliant':
        return PPEStatus.compliant;
      case 'noncompliant':
      case 'missing':
        return PPEStatus.missing;
      case 'partial':
      case 'not_suitable':
      case 'nonsuitable':
        return PPEStatus.notSuitable;
      default:
        return PPEStatus.missing;
    }
  }

  ComplianceStatus _parseOverallStatus(String status) {
    switch (status.toLowerCase()) {
      case 'compliant':
        return ComplianceStatus.compliant;
      case 'partial':
        return ComplianceStatus.partial;
      case 'noncompliant':
        return ComplianceStatus.nonCompliant;
      default:
        return ComplianceStatus.compliant;
    }
  }

  /// Disconnects from the WebSocket server.
  Future<void> disconnect() async {
    _reconnectionAttempts = 0;
    errorMessage.value = '';
    if (_client != null) {
      await _client!.close();
      _client = null;
    }
    isConnected.value = false;
  }

  /// Handles disconnection and schedules reconnection.
  void _handleDisconnection() {
    isConnected.value = false;
    _scheduleReconnection();
  }

  /// Schedules a reconnection attempt.
  void _scheduleReconnection() {
    if (_reconnectionAttempts < maxReconnectionAttempts) {
      _reconnectionAttempts++;
      Future.delayed(reconnectionDelay, () {
        if (!isConnected.value) {
          connect();
        }
      });
    } else {
      errorMessage.value = 'Max reconnection attempts reached';
    }
  }

  /// Disposes resources.
  void dispose() {
    disconnect();
    _detectionController.close();
  }
}

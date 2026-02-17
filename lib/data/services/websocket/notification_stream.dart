import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import '../../models/notification.dart' as models;
import 'stream_client.dart';
import 'package:safesight/core/constants/api_constants.dart';

/// Notification Stream WebSocket service for real-time PPE violation alerts.
///
/// Manages WebSocket connection for receiving notifications
/// and provides reconnection logic for connection failures.
class NotificationStream {
  /// The WebSocket client instance
  StreamClient? _client;

  /// Stream controller for notifications
  final StreamController<models.Notification> _notificationController =
      StreamController<models.Notification>.broadcast();

  /// Stream of notifications
  Stream<models.Notification> get notificationStream => _notificationController.stream;

  /// Observable connection state (for GetX)
  final RxBool isConnected = false.obs;

  /// Observable error state (for GetX)
  final RxString errorMessage = ''.obs;

  /// Observable list of received notifications
  final RxList<models.Notification> notifications = <models.Notification>[].obs;

  /// Unread notification count
  final RxInt unreadCount = 0.obs;

  /// WebSocket URL
  final String wsUrl;

  /// Reconnection delay
  static const Duration reconnectionDelay = Duration(seconds: 3);

  /// Maximum reconnection attempts
  static const int maxReconnectionAttempts = 5;

  /// Current reconnection attempt count
  int _reconnectionAttempts = 0;

  /// User information for authentication
  String? _userId;
  String? _role;
  String? _workerId;

  /// Creates a new NotificationStream instance.
  NotificationStream({String? wsUrl})
      : wsUrl = wsUrl ?? '${ApiConstants.wsUrl}${ApiConstants.wsNotifications}';

  /// Connects to the WebSocket server.
  ///
  /// Requires user information for authentication and channel subscription.
  Future<void> connect({
    required String userId,
    required String role,
    String? workerId,
  }) async {
    _userId = userId;
    _role = role;
    _workerId = workerId;

    try {
      // Build URL with query parameters for authentication
      final queryParams = <String, String>{
        'user_id': userId,
        'role': role,
      };
      if (workerId != null) {
        queryParams['worker_id'] = workerId;
      }

      final uri = Uri.parse(wsUrl).replace(queryParameters: queryParams);
      _client = StreamClient.connect(uri.toString());

      isConnected.value = true;
      errorMessage.value = '';
      _reconnectionAttempts = 0;

      // Listen for incoming messages
      _client!.stream.listen(
        (dynamic message) {
          try {
            Map<String, dynamic> jsonData;

            if (message is String) {
              jsonData = json.decode(message) as Map<String, dynamic>;
            } else if (message is List<int>) {
              final jsonString = utf8.decode(message as List<int>);
              jsonData = json.decode(jsonString) as Map<String, dynamic>;
            } else {
              jsonData = message as Map<String, dynamic>;
            }

            _handleMessage(jsonData);
          } catch (e) {
            errorMessage.value = 'Failed to parse notification: $e';
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

  /// Handle incoming WebSocket message
  void _handleMessage(Map<String, dynamic> jsonData) {
    final messageType = jsonData['type'] as String?;

    switch (messageType) {
      case 'connected':
        // Connection acknowledgment
        print('Notification WebSocket connected: ${jsonData['message']}');
        break;

      case 'violation_notification':
      case 'violation':
        final notification = models.Notification.fromJson(jsonData);
        _addNotification(notification);
        break;

      case 'violation_resolved':
        final notification = models.Notification.fromJson(jsonData);
        _addNotification(notification);
        break;

      case 'system_alert':
        final notification = models.Notification.fromJson(jsonData);
        _addNotification(notification);
        break;

      case 'error':
        errorMessage.value = 'Server error: ${jsonData['message']}';
        break;

      case 'pong':
        // Ping/pong response, no action needed
        break;

      default:
        print('Unknown notification message type: $messageType');
    }
  }

  /// Add notification to list and notify listeners
  void _addNotification(models.Notification notification) {
    notifications.insert(0, notification);

    // Update unread count
    if (!notification.read) {
      unreadCount.value = notifications.where((n) => !n.read).length;
    }

    // Send to stream
    _notificationController.add(notification);
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !notifications[index].read) {
      notifications[index] = notifications[index].markAsRead();
      unreadCount.value = notifications.where((n) => !n.read).length;

      // Notify server
      sendMarkRead(notificationId);
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].read) {
        notifications[i] = notifications[i].markAsRead();
      }
    }
    unreadCount.value = 0;
  }

  /// Send mark as read request to server
  void sendMarkRead(String notificationId) {
    if (_client == null || _client!.isClosed) {
      return;
    }

    final message = {
      'type': 'mark_read',
      'notification_id': notificationId,
    };

    _client!.send(json.encode(message));
  }

  /// Send ping to server to keep connection alive
  void sendPing() {
    if (_client == null || _client!.isClosed) {
      return;
    }

    _client!.send(json.encode({'type': 'ping'}));
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
        if (!isConnected.value && _userId != null && _role != null) {
          connect(
            userId: _userId!,
            role: _role!,
            workerId: _workerId,
          );
        }
      });
    } else {
      errorMessage.value = 'Max reconnection attempts reached';
    }
  }

  /// Disposes resources.
  void dispose() {
    disconnect();
    _notificationController.close();
    notifications.clear();
    unreadCount.close();
  }
}

import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../core/constants/api_constants.dart';
import 'api/api_client.dart';

/// F5 — Firebase Cloud Messaging client.
///
/// All methods are defensive: if Firebase isn't configured (no
/// google-services.json) the whole thing no-ops and the app keeps working with
/// the /ws/notifications/ WebSocket as before.
class PushService extends GetxService {
  bool _available = false;

  /// Call once at startup. Safe even if Firebase isn't set up.
  Future<PushService> init() async {
    try {
      await Firebase.initializeApp();
      _available = true;
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      // Foreground messages -> simple in-app snackbar.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final n = message.notification;
        if (n != null) {
          Get.snackbar(n.title ?? 'SafeEye', n.body ?? '',
              snackPosition: SnackPosition.TOP);
        }
      });

      // Re-register if the token rotates.
      messaging.onTokenRefresh.listen((_) => syncToken());
    } catch (e) {
      _available = false;
      dev.log('Firebase not configured; push disabled ($e)', name: 'PushService');
    }
    return this;
  }

  /// Send the device token to the backend. Call after login (worker accounts).
  Future<void> syncToken() async {
    if (!_available) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      if (!Get.isRegistered<ApiClient>()) return;
      await Get.find<ApiClient>().post(
        '/auth/fcm-token/'.fullPath,
        data: {'token': token, 'fcm_token': token},
      );
    } catch (e) {
      dev.log('syncToken failed: $e', name: 'PushService');
    }
  }
}

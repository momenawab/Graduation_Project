import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';

/// Network connectivity service for monitoring connection status.
///
/// Provides real-time connectivity updates and offline detection.
@immutable
class ConnectivityService extends GetxService {
  /// Singleton instance
  static ConnectivityService? _instance;

  /// Connectivity plus instance
  final Connectivity _connectivity;

  /// Stream subscription for connectivity updates
  StreamSubscription<ConnectivityResult>? _subscription;

  /// Observable connection status
  final RxBool isConnected = true.obs;

  /// Observable connection type
  final RxString connectionType = ''.obs;

  /// Creates a new ConnectivityService instance.
  ConnectivityService._({required Connectivity connectivity})
    : _connectivity = connectivity;

  /// Gets the singleton instance of ConnectivityService.
  static ConnectivityService getInstance() {
    if (_instance == null) {
      _instance = ConnectivityService._(connectivity: Connectivity());
      _instance!._initialize();
    }
    return _instance!;
  }

  /// Initializes connectivity monitoring.
  void _initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );

    // Check initial status
    _checkInitialStatus();
  }

  /// Checks initial connection status.
  Future<void> _checkInitialStatus() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  /// Updates connection status from connectivity result.
  void _updateConnectionStatus(ConnectivityResult result) {
    isConnected.value = result != ConnectivityResult.none;

    switch (result) {
      case ConnectivityResult.wifi:
        connectionType.value = 'wifi';
        break;
      case ConnectivityResult.ethernet:
        connectionType.value = 'ethernet';
        break;
      case ConnectivityResult.mobile:
        connectionType.value = 'mobile';
        break;
      case ConnectivityResult.bluetooth:
        connectionType.value = 'bluetooth';
        break;
      case ConnectivityResult.vpn:
        connectionType.value = 'vpn';
        break;
      case ConnectivityResult.other:
        connectionType.value = 'other';
        break;
      case ConnectivityResult.none:
        connectionType.value = 'none';
        break;
    }
  }

  /// Checks if device is currently online.
  bool get isOnline => isConnected.value;

  /// Checks if device is currently offline.
  bool get isOffline => !isConnected.value;

  /// Gets the current connection type.
  String get currentConnectionType => connectionType.value;

  /// Checks if connection is WiFi.
  bool get isWifi => connectionType.value == 'wifi';

  /// Checks if connection is mobile data.
  bool get isMobile => connectionType.value == 'mobile';

  /// Manually refreshes connection status.
  Future<void> refresh() async {
    await _checkInitialStatus();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    isConnected.close();
    connectionType.close();
    super.onClose();
  }
}

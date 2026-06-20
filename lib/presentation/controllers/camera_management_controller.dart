import 'package:get/get.dart';
import '../../data/services/api/camera_api.dart';

/// Controller for the Camera Management screen — list, add (with per-camera
/// required PPE), and delete cameras via the backend.
class CameraManagementController extends GetxController {
  late final CameraApi _api;

  final RxList<Map<String, dynamic>> cameras = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _api = Get.find<CameraApi>();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      error.value = '';
      cameras.value = await _api.getCameras();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => load();

  /// Creates a camera with its per-zone PPE policy. Returns true on success.
  Future<bool> addCamera({
    required String name,
    String? ip,
    String? location,
    required List<String> requiredPpe,
  }) async {
    try {
      isSaving.value = true;
      error.value = '';
      await _api.addCamera(
        name: name,
        ipAddress: (ip == null || ip.isEmpty) ? null : ip,
        location: (location == null || location.isEmpty) ? null : location,
        requiredPpe: requiredPpe,
      );
      await load();
      return true;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> removeCamera(int id) async {
    try {
      await _api.deleteCamera(id);
      await load();
    } catch (e) {
      error.value = e.toString();
    }
  }

  int get onlineCount =>
      cameras.where((c) => (c['status'] as String?) == 'online').length;

  @override
  void onClose() {
    cameras.close();
    isLoading.close();
    isSaving.close();
    error.close();
    super.onClose();
  }
}

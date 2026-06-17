import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/api/api_client.dart';
import '../../data/services/api/incident_api.dart';

/// F15 — controller for the "Report Incident" form.
class ReportIncidentController extends GetxController {
  late final IncidentApi _api;

  final title = ''.obs;
  final severity = 'medium'.obs;
  final location = ''.obs;
  final description = ''.obs;
  final Rx<File?> photo = Rx<File?>(null);
  final isSubmitting = false.obs;
  final error = ''.obs;

  final severities = const ['low', 'medium', 'high', 'critical'];

  @override
  void onInit() {
    super.onInit();
    _api = IncidentApi(apiClient: Get.find<ApiClient>());
  }

  Future<void> pickPhoto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x != null) photo.value = File(x.path);
  }

  Future<bool> submit() async {
    error.value = '';
    if (title.value.trim().isEmpty) {
      error.value = 'Title is required.';
      return false;
    }
    isSubmitting.value = true;
    try {
      await _api.createIncident(
        title: title.value.trim(),
        severity: severity.value,
        location: location.value.trim().isEmpty ? null : location.value.trim(),
        description:
            description.value.trim().isEmpty ? null : description.value.trim(),
        photo: photo.value,
      );
      return true;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}

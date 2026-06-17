import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../controllers/report_incident_controller.dart';

/// F15 — manual incident / near-miss reporting form.
class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReportIncidentController());
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title *'),
              onChanged: (v) => c.title.value = v,
            ),
            const SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<String>(
                  value: c.severity.value,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: c.severities
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => c.severity.value = v ?? 'medium',
                )),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Location'),
              onChanged: (v) => c.location.value = v,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
              onChanged: (v) => c.description.value = v,
            ),
            const SizedBox(height: 16),
            Obx(() => OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: Text(c.photo.value == null ? 'Attach photo' : 'Photo attached ✓'),
                  onPressed: c.pickPhoto,
                )),
            const SizedBox(height: 16),
            Obx(() => c.error.value.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(c.error.value, style: const TextStyle(color: AppColors.error)),
                  )),
            Obx(() => ElevatedButton(
                  onPressed: c.isSubmitting.value
                      ? null
                      : () async {
                          final ok = await c.submit();
                          if (ok) {
                            Get.back();
                            Get.snackbar('Reported', 'Incident submitted.',
                                snackPosition: SnackPosition.BOTTOM);
                          }
                        },
                  child: Text(c.isSubmitting.value ? 'Submitting…' : 'Submit Incident'),
                )),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/camera_management_controller.dart';
import '../widgets/common/ambient_backdrop.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart' as styles;

/// The 4 PPE classes the YOLOv11 model reliably detects (key -> label).
const List<(String, String)> kPpeOptions = [
  ('hardHat', 'Hard Hat'),
  ('vest', 'Safety Vest'),
  ('gloves', 'Gloves'),
  ('steelToedBoots', 'Steel-toed Boots'),
];
const Map<String, String> _ppeLabel = {
  'hardHat': 'Hard Hat',
  'vest': 'Safety Vest',
  'gloves': 'Gloves',
  'steelToedBoots': 'Steel-toed Boots',
};

/// Camera Management — list cameras and add a camera with its per-zone PPE policy.
@immutable
class CameraManagementScreen extends StatelessWidget {
  const CameraManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CameraManagementController());

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Camera'),
        onPressed: () => _openAddSheet(context, c),
      ),
      body: Stack(
        children: [
          const AmbientBackdrop(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _header(c)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
                Expanded(child: _content(c)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(CameraManagementController c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: -2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.videocam_outlined, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monitoring',
                    style: styles.AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Cameras',
                    style: styles.AppTextStyles.headlineSmall.copyWith(fontSize: 22)),
              ],
            ),
          ),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Text('${c.onlineCount} online',
                    style: styles.AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success, fontWeight: FontWeight.w700)),
              )),
        ],
      ),
    );
  }

  Widget _content(CameraManagementController c) {
    return Obx(() {
      if (c.isLoading.value && c.cameras.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }
      if (c.cameras.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam_off_outlined,
                    color: AppColors.textSecondary, size: 56),
                const SizedBox(height: 16),
                Text('No cameras yet',
                    style: styles.AppTextStyles.bodyLarge
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Tap “Add Camera” to register a feed and choose what PPE it should enforce.',
                    textAlign: TextAlign.center,
                    style: styles.AppTextStyles.bodyMedium),
              ],
            ),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: c.refresh,
        color: AppColors.primary,
        backgroundColor: AppColors.cardBackground,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          itemCount: c.cameras.length,
          itemBuilder: (_, i) => _CameraCard(camera: c.cameras[i], controller: c)
              .animate()
              .fadeIn(delay: (40 * (i % 12)).ms, duration: 300.ms),
        ),
      );
    });
  }

  void _openAddSheet(BuildContext context, CameraManagementController c) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCameraSheet(controller: c),
    );
  }
}

class _CameraCard extends StatelessWidget {
  final Map<String, dynamic> camera;
  final CameraManagementController controller;
  const _CameraCard({required this.camera, required this.controller});

  @override
  Widget build(BuildContext context) {
    final status = (camera['status'] as String?) ?? 'offline';
    final tone = status == 'online'
        ? AppColors.success
        : status == 'error'
            ? AppColors.error
            : AppColors.warning;
    final ppe = (camera['required_ppe'] as List?)?.cast<String>() ??
        kPpeOptions.map((e) => e.$1).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.videocam, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(camera['name']?.toString() ?? 'Camera',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.AppTextStyles.bodyLarge
                            .copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      (camera['location'] as String?)?.isNotEmpty == true
                          ? camera['location'] as String
                          : (camera['ip_address']?.toString() ?? '—'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: tone.withValues(alpha: 0.4)),
                ),
                child: Text(status[0].toUpperCase() + status.substring(1),
                    style: styles.AppTextStyles.bodySmall.copyWith(
                        color: tone, fontWeight: FontWeight.w700, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ppe
                      .map((k) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: AppColors.accent.withValues(alpha: 0.28)),
                            ),
                            child: Text(_ppeLabel[k] ?? k,
                                style: styles.AppTextStyles.bodySmall.copyWith(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600)),
                          ))
                      .toList(),
                ),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(context),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete camera?', style: styles.AppTextStyles.headlineSmall),
        content: Text('“${camera['name']}” will be removed.',
            style: styles.AppTextStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              final id = camera['id'];
              if (id is int) controller.removeCamera(id);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet form to add a camera and pick its required PPE.
class _AddCameraSheet extends StatefulWidget {
  final CameraManagementController controller;
  const _AddCameraSheet({required this.controller});

  @override
  State<_AddCameraSheet> createState() => _AddCameraSheetState();
}

class _AddCameraSheetState extends State<_AddCameraSheet> {
  final _name = TextEditingController();
  final _ip = TextEditingController();
  final _location = TextEditingController();
  // Default: all four PPE classes selected.
  final Set<String> _ppe = kPpeOptions.map((e) => e.$1).toSet();
  String? _formError;

  @override
  void dispose() {
    _name.dispose();
    _ip.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _formError = 'Camera name is required.');
      return;
    }
    setState(() => _formError = null);
    final ok = await widget.controller.addCamera(
      name: _name.text.trim(),
      ip: _ip.text.trim(),
      location: _location.text.trim(),
      requiredPpe: _ppe.toList(),
    );
    if (ok && mounted) {
      Get.back();
    } else if (mounted) {
      setState(() => _formError = widget.controller.error.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.border),
            left: BorderSide(color: AppColors.border),
            right: BorderSide(color: AppColors.border),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Add New Camera',
                style: styles.AppTextStyles.headlineSmall.copyWith(fontSize: 20)),
            const SizedBox(height: 16),
            _field('Camera name', _name, 'e.g. Assembly Line 3'),
            const SizedBox(height: 12),
            _field('IP address / stream URL', _ip, 'rtsp://… or 192.168.1.20'),
            const SizedBox(height: 12),
            _field('Location', _location, 'e.g. Warehouse Section A'),
            const SizedBox(height: 18),
            Text('Required PPE to detect',
                style: styles.AppTextStyles.label
                    .copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kPpeOptions.map((opt) {
                final active = _ppe.contains(opt.$1);
                return GestureDetector(
                  onTap: () => setState(() {
                    active ? _ppe.remove(opt.$1) : _ppe.add(opt.$1);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary.withValues(alpha: 0.22)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active
                            ? AppColors.accent.withValues(alpha: 0.6)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (active) ...[
                          const Icon(Icons.check, size: 13, color: AppColors.accent),
                          const SizedBox(width: 6),
                        ],
                        Text(opt.$2,
                            style: styles.AppTextStyles.bodySmall.copyWith(
                              color: active
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text('A violation is flagged when a worker is missing any selected item.',
                style: styles.AppTextStyles.bodySmall.copyWith(fontSize: 11)),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              Text(_formError!, style: styles.AppTextStyles.error),
            ],
            const SizedBox(height: 20),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.controller.isSaving.value ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: widget.controller.isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Text('Add Camera',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: styles.AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: styles.AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: styles.AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textDisabled),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

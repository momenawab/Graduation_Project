import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

/// Floating liquid-glass bottom navigation bar.
///
/// Wraps `GlassBottomBar` from `sdegenaar/liquid_glass_widgets`, which renders a
/// real shader-based frosted glass surface with a morphing selection indicator.
/// The effect is richest on Impeller (iOS + modern Android) and degrades
/// gracefully elsewhere.
///
/// API is kept source-compatible with the previous [BottomNavBar]: pass
/// [currentIndex] and an optional [onTap]. Place it in
/// `Scaffold.bottomNavigationBar` and set `extendBody: true` on the Scaffold so
/// page content scrolls behind the glass for the best effect.
@immutable
class BottomNavBar extends StatelessWidget {
  /// Current route index.
  final int currentIndex;

  /// Optional callback fired before navigation when a tab is tapped.
  final ValueChanged<int>? onTap;

  /// Selected item color (defaults to brand accent).
  final Color? selectedItemColor;

  /// Unselected item color (defaults to secondary text).
  final Color? unselectedItemColor;

  /// Kept for source compatibility; no longer used by the glass renderer.
  final Color? backgroundColor;
  final double elevation;

  const BottomNavBar({
    required this.currentIndex,
    this.onTap,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.backgroundColor,
    this.elevation = 8,
    super.key,
  });

  static const List<GlassBottomBarTab> _tabs = [
    GlassBottomBarTab(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    GlassBottomBarTab(
      icon: Icon(Icons.people_outline),
      activeIcon: Icon(Icons.people),
      label: 'Workers',
    ),
    GlassBottomBarTab(
      icon: Icon(Icons.insert_chart_outlined),
      activeIcon: Icon(Icons.insert_chart),
      label: 'Reports',
    ),
    GlassBottomBarTab(
      icon: Icon(Icons.settings_outlined),
      activeIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: GlassBottomBar(
        selectedIndex: currentIndex,
        onTabSelected: _handleTap,
        tabs: _tabs,
        selectedIconColor: selectedItemColor ?? AppColors.accent,
        unselectedIconColor: unselectedItemColor ?? AppColors.textSecondary,
        indicatorColor: (selectedItemColor ?? AppColors.accent)
            .withValues(alpha: 0.18),
        settings: const LiquidGlassSettings(
          blur: 12,
          glassColor: Color(0x1A2563EB), // faint brand-blue tint
        ),
      ),
    );
  }

  void _handleTap(int index) {
    onTap?.call(index);
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Get.offAllNamed(AppRoutes.HOME);
        break;
      case 1:
        Get.offAllNamed(AppRoutes.WORKERS_LIST);
        break;
      case 2:
        Get.offAllNamed(AppRoutes.REPORTS);
        break;
      case 3:
        Get.offAllNamed(AppRoutes.SETTINGS);
        break;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';
import '../../../routes/app_routes.dart';

/// Custom bottom navigation bar widget with route-based navigation.
@immutable
class BottomNavBar extends StatelessWidget {
  /// Current route index
  final int currentIndex;

  /// Callback when tab is tapped
  final ValueChanged<int>? onTap;

  /// Background color (defaults to card background)
  final Color? backgroundColor;

  /// Selected item color (defaults to primary)
  final Color? selectedItemColor;

  /// Unselected item color (defaults to text secondary)
  final Color? unselectedItemColor;

  /// Elevation (defaults to 8)
  final double elevation;

  const BottomNavBar({
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (onTap != null) {
            onTap!(index);
          }
          _navigateToRoute(index);
        },
        backgroundColor: backgroundColor ?? AppColors.cardBackground,
        selectedItemColor: selectedItemColor ?? AppColors.primary,
        unselectedItemColor: unselectedItemColor ?? AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: elevation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Workers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined),
            activeIcon: Icon(Icons.insert_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _navigateToRoute(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed(AppRoutes.HOME);
        break;
      case 1:
        Get.offAllNamed(AppRoutes.MONITORING);
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

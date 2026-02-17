import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';

/// Custom top app bar widget with title, actions, and optional back button.
@immutable
class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar title
  final String title;

  /// Optional leading widget (defaults to back button if showBackButton is true)
  final Widget? leading;

  /// Whether to show back button (defaults to false)
  final bool showBackButton;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Action widgets to display on the right side
  final List<Widget>? actions;

  /// App bar background color (defaults to transparent)
  final Color? backgroundColor;

  /// App bar elevation (defaults to 0)
  final double elevation;

  /// App bar height
  final double? height;

  /// Whether app bar is centered title (defaults to false)
  final bool centerTitle;

  const TopAppBar({
    required this.title,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.height,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(height ?? kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final effectiveLeading =
        leading ??
        (showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textPrimary,
                ),
                onPressed:
                    onBackPressed ??
                    () {
                      Navigator.of(context).pop();
                    },
              )
            : null);

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: effectiveLeading,
      actions: actions,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation,
      centerTitle: centerTitle,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }
}

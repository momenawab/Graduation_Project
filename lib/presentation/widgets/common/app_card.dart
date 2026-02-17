import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../../core/constants/app_colors.dart';

/// Standard card widget with customizable content, padding, and styling.
@immutable
class AppCard extends StatelessWidget {
  /// Card content widget
  final Widget child;

  /// Card elevation (defaults to 2)
  final double elevation;

  /// Card border radius (defaults to 12)
  final double borderRadius;

  /// Card padding (defaults to 16)
  final EdgeInsetsGeometry padding;

  /// Card background color (defaults to card color from theme)
  final Color? backgroundColor;

  /// Card border (optional)
  final BoxBorder? border;

  /// Card margin (defaults to zero)
  final EdgeInsetsGeometry margin;

  /// Optional onTap callback for making card tappable
  final VoidCallback? onTap;

  /// Optional onLongPress callback
  final VoidCallback? onLongPress;

  const AppCard({
    required this.child,
    this.elevation = 2,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.border,
    this.margin = EdgeInsets.zero,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null || onLongPress != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return card;
  }
}

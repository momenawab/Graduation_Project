import 'package:flutter/material.dart';

/// Soft radial brand glow pinned to the top corner, giving screens depth behind
/// their content. Shared across the home, workers and reports screens so the
/// modern look stays consistent.
@immutable
class AmbientBackdrop extends StatelessWidget {
  /// Horizontal anchor of the glow (-1 = left, 1 = right).
  final double alignX;

  const AmbientBackdrop({super.key, this.alignX = -0.9});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(alignX, -1.1),
            radius: 1.2,
            colors: const [Color(0x332563EB), Color(0x000B1220)],
          ),
        ),
      ),
    );
  }
}

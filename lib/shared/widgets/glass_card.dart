import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32), // Your Squircle radius
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // The 20px blur
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15), // 15% White fill
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3), // 1px light edge
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
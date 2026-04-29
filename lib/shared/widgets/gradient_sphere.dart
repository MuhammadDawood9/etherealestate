import 'package:flutter/material.dart';

class GradientSphere extends StatelessWidget {
  final Color color;
  final double size;

  const GradientSphere({super.key, required this.color, this.size = 600});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          radius: 0.8,
        ),
      ),
    );
  }
}

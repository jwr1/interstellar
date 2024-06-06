import 'dart:math';

import 'package:flutter/material.dart';

class CakeDayIcon extends StatelessWidget {
  const CakeDayIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Cake Day',
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect bounds) => const LinearGradient(
          transform: GradientRotation(pi / 2),
          stops: [0, 0.5, 1],
          colors: [
            Colors.yellow,
            Colors.pink,
            Colors.blue,
          ],
        ).createShader(bounds),
        child: const Icon(Icons.cake),
      ),
    );
  }
}

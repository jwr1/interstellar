import 'dart:math';

import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/utils.dart';

class UserStatusIcons extends StatelessWidget {
  final DateTime? cakeDay;
  final bool isBot;

  const UserStatusIcons({
    required this.cakeDay,
    required this.isBot,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    Widget? botWidget;
    Widget? cakeDayWidget;

    if (isBot) {
      botWidget = Tooltip(
        message: l(context).botAccount,
        child: const Icon(Icons.smart_toy_outlined),
      );
    }

    if (cakeDay == null) {
    } else if (now.difference(cakeDay!).inDays <= 14) {
      cakeDayWidget = Tooltip(
        message: l(context).newUser,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) => const LinearGradient(
            transform: GradientRotation(pi / 2),
            stops: [0, 1],
            colors: [
              Colors.green,
              Colors.lightGreen,
            ],
          ).createShader(bounds),
          child: const ImageIcon(
            AssetImage('assets/icons/plant.png'),
          ),
        ),
      );
    } else if (cakeDay!.day == now.day && cakeDay!.month == now.month) {
      cakeDayWidget = Tooltip(
        message: l(context).cakeDay,
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

    return Row(
      children: [
        if (botWidget != null) botWidget,
        if (cakeDayWidget != null) cakeDayWidget,
      ]
          .map((widget) => Padding(
                padding: const EdgeInsets.only(left: 5),
                child: widget,
              ))
          .toList(),
    );
  }
}

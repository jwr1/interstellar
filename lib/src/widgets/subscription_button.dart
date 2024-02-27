import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/utils.dart';

class SubscriptionButton extends StatelessWidget {
  final int subsCount;
  final bool isSubed;
  final void Function()? onPress;

  const SubscriptionButton({
    required this.subsCount,
    required this.isSubed,
    required this.onPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = Row(
      children: [
        const Icon(Icons.group),
        Text(' ${intFormat(subsCount)}'),
      ],
    );

    return isSubed
        ? FilledButton.tonal(
            onPressed: onPress,
            child: buttonChild,
          )
        : OutlinedButton(
            onPressed: onPress,
            child: buttonChild,
          );
  }
}

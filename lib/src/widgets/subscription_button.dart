import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/loading_button.dart';

class SubscriptionButton extends StatelessWidget {
  final int subsCount;
  final bool isSubed;
  final Future<void> Function()? onPress;

  const SubscriptionButton({
    required this.subsCount,
    required this.isSubed,
    required this.onPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isSubed
        ? LoadingTonalButton(
            onPressed: onPress,
            label: Text(intFormat(subsCount)),
            icon: const Icon(Icons.group),
          )
        : LoadingOutlinedButton(
            onPressed: onPress,
            label: Text(intFormat(subsCount)),
            icon: const Icon(Icons.group),
          );
  }
}

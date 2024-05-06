import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/settings/settings_controller.dart';
import 'package:provider/provider.dart';

class StarButton extends StatelessWidget {
  final String name;

  const StarButton(
    this.name, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isStarred = context.watch<SettingsController>().stars.contains(name);

    return IconButton(
      onPressed: isStarred
          ? () => context.read<SettingsController>().removeStar(name)
          : () => context.read<SettingsController>().addStar(name),
      icon: context.read<SettingsController>().stars.contains(name)
          ? const Icon(Icons.star)
          : const Icon(Icons.star_border),
      color: isStarred ? Colors.yellow : null,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:interstellar/src/widgets/avatar.dart';

class DisplayName extends StatelessWidget {
  const DisplayName(this.name, {super.key, this.icon, this.onTap});

  final String name;
  final String? icon;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    var nameTuple =
        (name.startsWith('@') ? name.substring(1) : name).split('@');
    String localName = nameTuple.first;
    String? hostName = nameTuple.length > 1 ? nameTuple[1] : null;

    return Row(
      children: [
        if (icon != null)
          Padding(
              padding: const EdgeInsets.only(right: 3),
              child: Avatar(icon!, radius: 14)),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Text(
              localName,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        if (hostName != null)
          Tooltip(
            message: hostName,
            triggerMode: TooltipTriggerMode.tap,
            child: const Padding(
              padding: EdgeInsets.fromLTRB(2, 3, 3, 3),
              child: Text('@'),
            ),
          ),
      ],
    );
  }
}

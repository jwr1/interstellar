import 'package:flutter/material.dart';

class DisplayName extends StatelessWidget {
  const DisplayName(this.name, {super.key, this.onTap});

  final String name;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    var nameTuple =
        (name.startsWith('@') ? name.substring(1) : name).split('@');
    String localName = nameTuple.first;
    String? hostName = nameTuple.length > 1 ? nameTuple[1] : null;

    return Row(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
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
              padding: EdgeInsets.all(2.0),
              child: Text('@'),
            ),
          ),
      ],
    );
  }
}

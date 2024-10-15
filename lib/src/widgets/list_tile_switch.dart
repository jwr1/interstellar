import 'package:flutter/material.dart';

class ListTileSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool)? onChanged;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;

  const ListTileSwitch({
    required this.value,
    required this.onChanged,
    this.leading,
    this.title,
    this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = onChanged == null ? Theme.of(context).disabledColor : null;

    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: Switch(value: value, onChanged: onChanged),
      textColor: color,
      iconColor: color,
    );
  }
}

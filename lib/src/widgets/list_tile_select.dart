import 'package:flutter/material.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:material_symbols_icons/symbols.dart';

class ListTileSelect<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final SelectionMenu<T> selectionMenu;
  final T value;
  final T? oldValue;
  final void Function(T newValue) onChange;

  const ListTileSelect({
    super.key,
    required this.title,
    required this.icon,
    required this.selectionMenu,
    required this.value,
    required this.oldValue,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final curOption = selectionMenu.getOption(value);

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(curOption.icon, size: 20),
          const SizedBox(width: 4),
          Text(curOption.title),
          const Icon(Symbols.arrow_drop_down_rounded),
        ],
      ),
      onTap: () async {
        final newValue = await selectionMenu.askSelection(context, oldValue);

        if (newValue == null) return;

        onChange(newValue);
      },
    );
  }
}

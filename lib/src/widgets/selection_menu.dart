import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class SelectionMenuItem<T> {
  final T value;
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final String? subtitle;
  final List<SelectionMenuItem<T>>? subItems;

  const SelectionMenuItem({
    required this.value,
    required this.title,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.subItems,
  });
}

class SelectionMenu<T> {
  final String title;
  final List<SelectionMenuItem<T>> options;

  const SelectionMenu(this.title, this.options);

  Future<T?> askSelection(
    BuildContext context,
    T? oldSelection,
  ) async =>
      showModalBottomSheet<T>(
        context: context,
        builder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: ListView(shrinkWrap: true, children: [
                  ...options.map(
                    (option) => ListTile(
                      title: Text(option.title),
                      onTap: () => Navigator.pop(context, option.value),
                      leading: Icon(option.icon, color: option.iconColor),
                      selected: oldSelection == option.value,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.2),
                      subtitle: option.subtitle != null
                          ? Text(option.subtitle!)
                          : null,
                      trailing:
                          option.subItems != null && option.subItems!.isNotEmpty
                          ? GestureDetector(
                              onTap: () async {
                                final subSelection = await SelectionMenu<T>(
                                    'sort', option.subItems!)
                                    .askSelection(context, oldSelection);
                                if (!context.mounted) return;
                                Navigator.pop(context, subSelection);
                              },
                              child: Icon(Icons.arrow_right),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                ]),
              ),
            ],
          );
        },
      );

  SelectionMenuItem<T> getOption(T value) {
    final option = options.firstWhereOrNull(
      (option) => option.value == value,
    );
    if (option != null) return option;
    for (var option in options) {
      if (option.subItems == null) continue;
      final subOption = option.subItems!.firstWhereOrNull(
        (option) => option.value == value,
      );
      if (subOption != null) return subOption;
    }
    return SelectionMenuItem(value: value, title: title);
  }
}

import 'package:flutter/material.dart';

class SelectionMenuItem<T> {
  final T value;
  final String title;
  final IconData? icon;
  final Color? iconColor;

  const SelectionMenuItem({
    required this.value,
    required this.title,
    this.icon,
    this.iconColor,
  });
}

class SelectionMenu<T> {
  final String title;
  final List<SelectionMenuItem<T>> options;

  const SelectionMenu(this.title, this.options);

  Future<T?> inquireSelection(
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
    return options.firstWhere(
      (option) => option.value == value,
    );
  }
}

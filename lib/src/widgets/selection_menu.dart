import 'package:flutter/material.dart';

class SelectionMenuItem<T> {
  final T value;
  final String title;
  final IconData icon;

  const SelectionMenuItem({
    required this.value,
    required this.title,
    required this.icon,
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
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ...options.map((option) => ListTile(
                    title: Text(option.title),
                    onTap: () => Navigator.pop(context, option.value),
                    leading: Icon(option.icon),
                    selected: oldSelection == option.value,
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.2),
                  )),
              const SizedBox(height: 24),
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

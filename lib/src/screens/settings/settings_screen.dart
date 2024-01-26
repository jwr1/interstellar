import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/feed_screen.dart';
import 'package:interstellar/src/screens/settings/login.dart';

import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final currentDefaultFeedSort = feedSortSelect.options.firstWhere(
      (option) => option.value == controller.defaultFeedSort,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child:
                Text('Theme', style: Theme.of(context).textTheme.titleMedium),
          ),
          DropdownButton<ThemeMode>(
            value: controller.themeMode,
            onChanged: controller.updateThemeMode,
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System Theme'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light Theme'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark Theme'),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Feed', style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            title: const Text('Default Feed Sort'),
            leading: const Icon(Icons.sort),
            onTap: () async {
              controller.updateDefaultFeedSort(
                await feedSortSelect.inquireSelection(
                  context,
                  currentDefaultFeedSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultFeedSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultFeedSort.title),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Accounts',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          ...(controller.oauthCredentials.keys.toList()..sort())
              .map((account) => ListTile(
                    title: Text(
                      account,
                      style: TextStyle(
                        fontWeight: account == controller.selectedAccount
                            ? FontWeight.w800
                            : FontWeight.normal,
                      ),
                    ),
                    onTap: () => controller.setSelectedAccount(account),
                    trailing: IconButton(
                        onPressed: () {
                          showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Remove account'),
                              content: Text(account),
                              actions: <Widget>[
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    controller.removeOAuthCredentials(account);
                                  },
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline)),
                  )),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Add Account'),
          )
        ],
      ),
    );
  }
}

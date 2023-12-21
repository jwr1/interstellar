import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/settings/login.dart';

import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Theme', style: Theme.of(context).textTheme.headlineSmall),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Accounts',
                    style: Theme.of(context).textTheme.headlineSmall),
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
                                  builder: (BuildContext context) =>
                                      AlertDialog(
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
                                          controller
                                              .removeOAuthCredentials(account);
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
                    child: const Text('Add Account'))
              ],
            ),
          )
        ],
      ),
    );
  }
}

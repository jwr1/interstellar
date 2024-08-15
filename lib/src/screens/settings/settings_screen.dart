import 'package:flutter/material.dart';
import 'package:interstellar/src/screens/settings/action_settings.dart';
import 'package:interstellar/src/screens/settings/general_settings.dart';
import 'package:interstellar/src/screens/settings/login_select.dart';
import 'package:interstellar/src/widgets/settings_header.dart';
import 'package:provider/provider.dart';

import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ListTile(
            title: const Text('General Settings'),
            leading: const Icon(Icons.settings),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GeneralScreen(controller: controller),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Actions and Defaults'),
            leading: const Icon(Icons.toggle_on),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActionSettings(controller: controller),
                ),
              );
            },
          ),
          const SettingsHeader('Accounts'),
          ...(controller.accounts.keys.toList()
                ..sort((a, b) {
                  final [aLocal, aHost] = a.split('@');
                  final [bLocal, bHost] = b.split('@');

                  final hostCompare = aHost.compareTo(bHost);
                  if (hostCompare != 0) return hostCompare;

                  return aLocal.compareTo(bLocal);
                }))
              .map((account) => ListTile(
                    title: Text(
                      account,
                      style: TextStyle(
                        fontWeight: account == controller.selectedAccount
                            ? FontWeight.w800
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(controller
                        .servers[account.split('@').last]!.software.name),
                    onTap: () => controller.setSelectedAccount(account),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: controller.selectedAccount == account
                          ? null
                          : () {
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
                                        controller.removeAccount(account);
                                      },
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                            },
                    ),
                  )),
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginSelectScreen(),
                  ),
                );
              },
              child: const Text('Add Account'),
            ),
          ),
        ],
      ),
    );
  }
}

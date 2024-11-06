import 'package:flutter/material.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/screens/settings/about_screen.dart';
import 'package:interstellar/src/screens/settings/behavior_screen.dart';
import 'package:interstellar/src/screens/settings/display_screen.dart';
import 'package:interstellar/src/screens/settings/login_select.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/settings_header.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ac = context.watch<AppController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Symbols.settings_rounded),
            title: Text(l(context).settings_behavior),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BehaviorSettingsScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Symbols.palette_rounded),
            title: Text(l(context).settings_display),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DisplaySettingsScreen(),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Symbols.filter_list_rounded),
            title: Text(l(context).settings_feedActions),
            // onTap: () => Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => const SettingsScreen(),
            //   ),
            // ),
          ),
          ListTile(
            leading: const Icon(Symbols.tune_rounded),
            title: Text(l(context).settings_feedDefaults),
            // onTap: () => Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => const SettingsScreen(),
            //   ),
            // ),
          ),
          ListTile(
            leading: const Icon(Symbols.notifications_rounded),
            title: Text(l(context).settings_notifications),
            // onTap: () => Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => const SettingsScreen(),
            //   ),
            // ),
          ),
          ListTile(
            leading: const Icon(Symbols.info_rounded),
            title: Text(l(context).settings_about),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AboutScreen(),
              ),
            ),
          ),
          const Divider(),
          SettingsHeader(l(context).accounts),
          ...(ac.accounts.keys.toList()
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
                        fontWeight: account == ac.selectedAccount
                            ? FontWeight.w800
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                        ac.servers[account.split('@').last]!.software.name),
                    onTap: () => ac.switchAccounts(account),
                    trailing: IconButton(
                      icon: const Icon(Symbols.delete_rounded),
                      onPressed: ac.selectedAccount == account
                          ? null
                          : () {
                              showDialog<String>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text(l(context).removeAccount),
                                  content: Text(account),
                                  actions: <Widget>[
                                    OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(l(context).cancel),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        ac.removeAccount(account);
                                      },
                                      child: Text(l(context).remove),
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
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginSelectScreen(),
                ),
              ),
              child: Text(l(context).addAccount),
            ),
          ),
        ],
      ),
    );
  }
}

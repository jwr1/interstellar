import 'package:flutter/material.dart';
import 'package:interstellar/src/api/comments.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/screens/settings/login_select.dart';
import 'package:interstellar/src/utils/language_codes.dart';
import 'package:interstellar/src/utils/themes.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';

import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = themeModeSelect.getOption(controller.themeMode);
    final currentTheme = themeSelect.getOption(controller.accentColor);
    final currentDefaultFeedMode =
        feedTypeSelect.getOption(controller.defaultFeedType);
    final currentDefaultEntriesFeedSort =
        feedSortSelect.getOption(controller.defaultEntriesFeedSort);
    final currentDefaultPostsFeedSort =
        feedSortSelect.getOption(controller.defaultPostsFeedSort);
    final currentDefaultExploreFeedSort =
        feedSortSelect.getOption(controller.defaultExploreFeedSort);
    final currentDefaultCommentSort =
        commentSortSelect.getOption(controller.defaultCommentSort);

    final isLemmy = controller.serverSoftware == ServerSoftware.lemmy;
    final customLanguageFilterEnabled =
        !controller.useAccountLangFilter && !isLemmy;

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
          ListTile(
            title: const Text('Theme Mode'),
            leading: const Icon(Icons.brightness_medium),
            onTap: () async {
              controller.updateThemeMode(
                await themeModeSelect.inquireSelection(
                  context,
                  controller.themeMode,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentThemeMode.icon),
                const SizedBox(width: 4),
                Text(currentThemeMode.title),
              ],
            ),
          ),
          ListTile(
            title: const Text('Use Dynamic Color'),
            leading: const Icon(Icons.auto_awesome_rounded),
            onTap: () {
              controller.updateUseDynamicColor(!controller.useDynamicColor);
            },
            trailing: Switch(
              value: controller.useDynamicColor,
              onChanged: controller.updateUseDynamicColor,
            ),
          ),
          ListTile(
            title: const Text('Accent Color'),
            leading: const Icon(Icons.palette),
            onTap: () async {
              controller.updateAccentColor(
                await themeSelect.inquireSelection(
                  context,
                  currentTheme.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentTheme.icon, color: currentTheme.iconColor),
                const SizedBox(width: 4),
                Text(currentTheme.title),
              ],
            ),
            enabled: !controller.useDynamicColor,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Feed', style: Theme.of(context).textTheme.titleMedium),
          ),
          ListTile(
            title: const Text('Default Feed Type'),
            leading: const Icon(Icons.tab),
            enabled: !isLemmy,
            onTap: () async {
              controller.updateDefaultFeedType(
                await feedTypeSelect.inquireSelection(
                  context,
                  currentDefaultFeedMode.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultFeedMode.icon),
                const SizedBox(width: 4),
                Text(currentDefaultFeedMode.title),
              ],
            ),
          ),
          ListTile(
            title: const Text('Default Threads Feed Sort'),
            leading: const Icon(Icons.sort),
            onTap: () async {
              controller.updateDefaultEntriesFeedSort(
                await feedSortSelect.inquireSelection(
                  context,
                  currentDefaultEntriesFeedSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultEntriesFeedSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultEntriesFeedSort.title),
              ],
            ),
          ),
          ListTile(
            title: const Text('Default Microblog Feed Sort'),
            leading: const Icon(Icons.sort),
            enabled: !isLemmy,
            onTap: () async {
              controller.updateDefaultPostsFeedSort(
                await feedSortSelect.inquireSelection(
                  context,
                  currentDefaultPostsFeedSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultPostsFeedSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultPostsFeedSort.title),
              ],
            ),
          ),
          ListTile(
            title: const Text('Default Explore Feed Sort'),
            leading: const Icon(Icons.explore),
            onTap: () async {
              controller.updateDefaultExploreFeedSort(
                await feedSortSelect.inquireSelection(
                  context,
                  currentDefaultExploreFeedSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultExploreFeedSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultExploreFeedSort.title),
              ],
            ),
          ),
          ListTile(
            title: const Text('Default Comment Sort'),
            leading: const Icon(Icons.comment),
            onTap: () async {
              controller.updateDefaultCommentSort(
                await commentSortSelect.inquireSelection(
                  context,
                  currentDefaultCommentSort.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentDefaultCommentSort.icon),
                const SizedBox(width: 4),
                Text(currentDefaultCommentSort.title),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Language',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          SwitchListTile(
            title: const Text('Use Account Language Filter'),
            subtitle: const Text(
                'Please note: language filters only apply to "All" and explore feeds'),
            value: controller.useAccountLangFilter,
            onChanged: !isLemmy ? controller.updateUseAccountLangFilter : null,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Custom Language Filter',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: customLanguageFilterEnabled
                          ? null
                          : Theme.of(context).disabledColor),
                ),
              ),
              Flexible(
                child: Wrap(
                  children: [
                    ...(controller.langFilter.map(
                      (langCode) => Padding(
                        padding: const EdgeInsets.all(2),
                        child: InputChip(
                          isEnabled: customLanguageFilterEnabled,
                          label: Text(getLangName(langCode)),
                          onDeleted: () async {
                            controller.removeLangFilter(langCode);
                          },
                        ),
                      ),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(2),
                      child: IconButton(
                        onPressed: controller.useAccountLangFilter
                            ? null
                            : () async {
                                controller.addLangFilter(
                                  await languageSelectionMenu.inquireSelection(
                                      context, null),
                                );
                              },
                        icon: const Icon(Icons.add),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          ListTile(
            title: const Text('Default Create Language'),
            enabled: !isLemmy,
            onTap: () async {
              controller.updateDefaultCreateLang(
                await languageSelectionMenu.inquireSelection(
                  context,
                  controller.defaultCreateLang,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text(getLangName(controller.defaultCreateLang))],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Accounts',
                style: Theme.of(context).textTheme.titleMedium),
          ),
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
          )
        ],
      ),
    );
  }
}

const SelectionMenu<ThemeMode> themeModeSelect = SelectionMenu(
  'Theme Mode',
  [
    SelectionMenuItem(
      value: ThemeMode.system,
      title: 'System',
      icon: Icons.auto_mode,
    ),
    SelectionMenuItem(
      value: ThemeMode.light,
      title: 'Light',
      icon: Icons.light_mode,
    ),
    SelectionMenuItem(
      value: ThemeMode.dark,
      title: 'Dark',
      icon: Icons.dark_mode,
    ),
  ],
);

SelectionMenu<String> themeSelect = SelectionMenu(
  "Theme Accent Color",
  themes
      .map((themeInfo) => SelectionMenuItem(
            value: themeInfo.name,
            title: themeInfo.name,
            icon: Icons.brightness_1,
            iconColor: themeInfo.lightMode?.primary,
          ))
      .toList(),
);

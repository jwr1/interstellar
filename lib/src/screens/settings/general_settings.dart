import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/language_codes.dart';
import 'package:interstellar/src/utils/themes.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';

import 'settings_controller.dart';

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final isLemmy = controller.serverSoftware == ServerSoftware.lemmy;

    final currentThemeMode = themeModeSelect.getOption(controller.themeMode);
    final currentTheme = themeSelect.getOption(controller.accentColor);

    final customLanguageFilterEnabled =
        !controller.useAccountLangFilter && !isLemmy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
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
                await themeModeSelect.askSelection(
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
                await themeSelect.askSelection(
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
                                  await languageSelectionMenu.askSelection(
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
                await languageSelectionMenu.askSelection(
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

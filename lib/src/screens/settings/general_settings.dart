import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/language_codes.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:interstellar/src/widgets/settings_header.dart';

import 'settings_controller.dart';

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final isLemmy = controller.serverSoftware == ServerSoftware.lemmy;

    final currentThemeMode = themeModeSelect.getOption(controller.themeMode);
    final currentColorScheme = themeSelect.getOption(controller.colorScheme);

    final currentPostImagePosition =
        postLayoutSelect.getOption(controller.postImagePosition);

    final customLanguageFilterEnabled =
        !controller.useAccountLangFilter && !isLemmy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('General Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SettingsHeader('Theme'),
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
            title: const Text('Enable True Black'),
            leading: const Icon(Icons.brightness_1_outlined),
            onTap: () {
              controller.updateEnableTrueBlack(!controller.enableTrueBlack);
            },
            trailing: Switch(
              value: controller.enableTrueBlack,
              onChanged: controller.updateEnableTrueBlack,
            ),
            enabled: controller.themeMode != ThemeMode.light,
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
            title: const Text('Color Scheme'),
            leading: const Icon(Icons.palette),
            onTap: () async {
              controller.updateColorScheme(
                await themeSelect.askSelection(
                  context,
                  currentColorScheme.value,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentColorScheme.icon,
                    color: currentColorScheme.iconColor),
                const SizedBox(width: 4),
                Text(currentColorScheme.title),
              ],
            ),
            enabled: !controller.useDynamicColor,
          ),
          const SettingsHeader('Post Appearance'),
          ListTile(
            title: const Text('Image Position'),
            leading: const Icon(Icons.image),
            onTap: () async {
              controller.updatePostImagePosition(
                await postLayoutSelect.askSelection(
                  context,
                  controller.postImagePosition,
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentPostImagePosition.icon),
                const SizedBox(width: 4),
                Text(currentPostImagePosition.title),
              ],
            ),
          ),
          ListTile(
            title: const Text('Use Compact Preview'),
            leading: const Icon(Icons.view_agenda),
            onTap: () {
              controller
                  .updatePostCompactPreview(!controller.postCompactPreview);
            },
            trailing: Switch(
              value: controller.postCompactPreview,
              onChanged: controller.updatePostCompactPreview,
            ),
          ),
          const SettingsHeader('Language'),
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
          const SettingsHeader('Other'),
          ListTile(
            title: const Text('Always Show Instance'),
            leading: const Icon(Icons.public),
            onTap: () {
              controller
                  .updateAlwaysShowInstance(!controller.alwaysShowInstance);
            },
            trailing: Switch(
              value: controller.alwaysShowInstance,
              onChanged: controller.updateAlwaysShowInstance,
            ),
            subtitle: const Text(
                'When enabled, the instance of a user/magazine will always display instead of an @ button'),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text('Feed Filters',
                          style: Theme.of(context).textTheme.bodyLarge!),
                    ),
                    Flexible(
                      child: Wrap(
                        children: [
                          ...(controller.feedFilters.map(
                            (filter) => Padding(
                              padding: const EdgeInsets.all(2),
                              child: InputChip(
                                label: Text(filter),
                                onDeleted: () async {
                                  controller.removeFeedFilter(filter);
                                },
                              ),
                            ),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(2),
                            child: IconButton(
                              onPressed: () async {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Add Filter',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          TextFormField(
                                            autofocus: true,
                                            onFieldSubmitted: (String? filter) {
                                              controller.addFeedFilter(filter);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
                Text(
                  'Use this to filter out posts in your "Feed" (not Explore) that contain any of these patterns in their title or body. Simple words or phrases like "hello world" are allowed, but you can also use regular expressions (case insensitive) to match text with a complex pattern.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
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

final Map<FlexScheme, String> themeNameMap = {
  FlexScheme.blue: 'Blue',
  FlexScheme.indigo: 'Indigo',
  FlexScheme.hippieBlue: 'Hippie Blue',
  FlexScheme.aquaBlue: 'Aqua Blue',
  FlexScheme.brandBlue: 'Brand Blue',
  FlexScheme.deepBlue: 'Deep Blue',
  FlexScheme.sakura: 'Sakura',
  FlexScheme.mandyRed: 'Mandy Red',
  FlexScheme.red: 'Red',
  FlexScheme.redWine: 'Red Wine',
  FlexScheme.purpleBrown: 'Purple Brown',
  FlexScheme.green: 'Green',
  FlexScheme.money: 'Money',
  FlexScheme.jungle: 'Jungle',
  FlexScheme.greyLaw: 'Grey Law',
  FlexScheme.wasabi: 'Wasabi',
  FlexScheme.gold: 'Gold',
  FlexScheme.mango: 'Mango',
  FlexScheme.amber: 'Amber',
  FlexScheme.vesuviusBurn: 'Vesuvius Burn',
  FlexScheme.deepPurple: 'Deep Purple',
  FlexScheme.ebonyClay: 'Ebony Clay',
  FlexScheme.barossa: 'Barossa',
  FlexScheme.shark: 'Shark',
  FlexScheme.bigStone: 'Big Stone',
  FlexScheme.damask: 'Damask',
  FlexScheme.bahamaBlue: 'Bahama Blue',
  FlexScheme.mallardGreen: 'Mallard Green',
  FlexScheme.espresso: 'Espresso',
  FlexScheme.outerSpace: 'Outer Space',
  FlexScheme.blueWhale: 'Blue Whale',
  FlexScheme.sanJuanBlue: 'San Juan Blue',
  FlexScheme.rosewood: 'Rosewood',
  FlexScheme.blumineBlue: 'Blumine Blue',
  FlexScheme.flutterDash: 'Flutter Dash',
};

SelectionMenu<FlexScheme> themeSelect = SelectionMenu(
  'Theme Accent Color',
  themeNameMap.keys
      .map((theme) => SelectionMenuItem(
            value: theme,
            title: themeNameMap[theme]!,
            icon: Icons.brightness_1,
            iconColor: FlexColor.schemesWithCustom[theme]!.light.primary,
          ))
      .toList(),
);

// SelectionMenu<String> themeSelect = SelectionMenu(
//   'Theme Accent Color',
//   themes
//       .map((themeInfo) => SelectionMenuItem(
//             value: themeInfo.name,
//             title: themeInfo.name,
//             icon: Icons.brightness_1,
//             iconColor: themeInfo.lightMode?.primary,
//           ))
//       .toList(),
// );

const SelectionMenu<PostImagePosition> postLayoutSelect = SelectionMenu(
  'Post Image Position',
  [
    SelectionMenuItem(
      value: PostImagePosition.auto,
      title: 'Auto',
      icon: Icons.auto_mode,
    ),
    SelectionMenuItem(
      value: PostImagePosition.top,
      title: 'Top',
      icon: Icons.smartphone,
    ),
    SelectionMenuItem(
      value: PostImagePosition.right,
      title: 'Right',
      icon: Icons.tablet,
    ),
  ],
);

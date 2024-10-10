import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:interstellar/src/utils/language_codes.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/widgets/selection_menu.dart';
import 'package:interstellar/src/widgets/settings_header.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'settings_controller.dart';

class GeneralScreen extends StatelessWidget {
  const GeneralScreen({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final isLemmy = controller.serverSoftware == ServerSoftware.lemmy;

    final currentThemeMode =
        themeModeSelect(context).getOption(controller.themeMode);
    final currentColorScheme =
        themeSelect(context).getOption(controller.colorScheme);

    final currentPostImagePosition =
        postLayoutSelect.getOption(controller.postImagePosition);

    final customLanguageFilterEnabled =
        !controller.useAccountLangFilter && !isLemmy;

    return Scaffold(
      appBar: AppBar(
        title: Text(l(context).settings_general),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SettingsHeader(l(context).settings_theme),
          ListTile(
            title: Text(l(context).settings_themeMode),
            leading: const Icon(Symbols.brightness_medium_rounded),
            onTap: () async {
              controller.updateThemeMode(
                await themeModeSelect(context).askSelection(
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
            title: Text(l(context).settings_enableTrueBlack),
            leading: const Icon(Symbols.brightness_1_rounded),
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
            title: Text(l(context).settings_useDynamicColor),
            leading: const Icon(Symbols.nest_eco_leaf_rounded),
            onTap: () {
              controller.updateUseDynamicColor(!controller.useDynamicColor);
            },
            trailing: Switch(
              value: controller.useDynamicColor,
              onChanged: controller.updateUseDynamicColor,
            ),
          ),
          ListTile(
            title: Text(l(context).settings_colorScheme),
            leading: const Icon(Symbols.palette_rounded),
            onTap: () async {
              controller.updateColorScheme(
                await themeSelect(context).askSelection(
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
          SettingsHeader(l(context).settings_postAppearance),
          ListTile(
            title: const Text('Image Position'),
            leading: const Icon(Symbols.image_rounded),
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
            title: Text(l(context).settings_useCompactPreview),
            leading: const Icon(Symbols.view_agenda_rounded),
            onTap: () {
              controller
                  .updatePostCompactPreview(!controller.postCompactPreview);
            },
            trailing: Switch(
              value: controller.postCompactPreview,
              onChanged: controller.updatePostCompactPreview,
            ),
          ),
          SettingsHeader(l(context).settings_language),
          SwitchListTile(
            title: Text(l(context).settings_useAccountLangFilter),
            subtitle: Text(l(context).settings_useAccountLangFilter_help),
            value: controller.useAccountLangFilter,
            onChanged: !isLemmy ? controller.updateUseAccountLangFilter : null,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l(context).settings_customLanguageFilter,
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
                        icon: const Icon(Symbols.add_rounded),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          ListTile(
            title: Text(l(context).settings_defaultCreateLanguage),
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
          SettingsHeader(l(context).settings_other),
          ListTile(
            title: Text(l(context).settings_alwaysShowInstance),
            leading: const Icon(Symbols.public_rounded),
            onTap: () {
              controller
                  .updateAlwaysShowInstance(!controller.alwaysShowInstance);
            },
            trailing: Switch(
              value: controller.alwaysShowInstance,
              onChanged: controller.updateAlwaysShowInstance,
            ),
            subtitle: Text(l(context).settings_alwaysShowInstance_help),
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
                      child: Text(l(context).settings_feedFilters,
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
                                            l(context).settings_feedFilters_add,
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
                              icon: const Icon(Symbols.add_rounded),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Text(
                  l(context).settings_feedFilters_help,
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

SelectionMenu<ThemeMode> themeModeSelect(BuildContext context) => SelectionMenu(
      l(context).settings_themeMode,
      [
        SelectionMenuItem(
          value: ThemeMode.system,
          title: l(context).settings_themeMode_system,
          icon: Symbols.auto_mode_rounded,
        ),
        SelectionMenuItem(
          value: ThemeMode.light,
          title: l(context).settings_themeMode_light,
          icon: Symbols.light_mode_rounded,
        ),
        SelectionMenuItem(
          value: ThemeMode.dark,
          title: l(context).settings_themeMode_dark,
          icon: Symbols.dark_mode_rounded,
        ),
      ],
    );

Map<FlexScheme, String> themeNameMap(BuildContext context) => {
      FlexScheme.blue: l(context).settings_colorScheme_blue,
      FlexScheme.indigo: l(context).settings_colorScheme_indigo,
      FlexScheme.hippieBlue: l(context).settings_colorScheme_hippieBlue,
      FlexScheme.aquaBlue: l(context).settings_colorScheme_aquaBlue,
      FlexScheme.brandBlue: l(context).settings_colorScheme_brandBlue,
      FlexScheme.deepBlue: l(context).settings_colorScheme_deepBlue,
      FlexScheme.sakura: l(context).settings_colorScheme_sakura,
      FlexScheme.mandyRed: l(context).settings_colorScheme_mandyRed,
      FlexScheme.red: l(context).settings_colorScheme_red,
      FlexScheme.redWine: l(context).settings_colorScheme_redWine,
      FlexScheme.purpleBrown: l(context).settings_colorScheme_purpleBrown,
      FlexScheme.green: l(context).settings_colorScheme_green,
      FlexScheme.money: l(context).settings_colorScheme_money,
      FlexScheme.jungle: l(context).settings_colorScheme_jungle,
      FlexScheme.greyLaw: l(context).settings_colorScheme_greyLaw,
      FlexScheme.wasabi: l(context).settings_colorScheme_wasabi,
      FlexScheme.gold: l(context).settings_colorScheme_gold,
      FlexScheme.mango: l(context).settings_colorScheme_mango,
      FlexScheme.amber: l(context).settings_colorScheme_amber,
      FlexScheme.vesuviusBurn: l(context).settings_colorScheme_vesuviusBurn,
      FlexScheme.deepPurple: l(context).settings_colorScheme_deepPurple,
      FlexScheme.ebonyClay: l(context).settings_colorScheme_ebonyClay,
      FlexScheme.barossa: l(context).settings_colorScheme_barossa,
      FlexScheme.shark: l(context).settings_colorScheme_shark,
      FlexScheme.bigStone: l(context).settings_colorScheme_bigStone,
      FlexScheme.damask: l(context).settings_colorScheme_damask,
      FlexScheme.bahamaBlue: l(context).settings_colorScheme_bahamaBlue,
      FlexScheme.mallardGreen: l(context).settings_colorScheme_mallardGreen,
      FlexScheme.espresso: l(context).settings_colorScheme_espresso,
      FlexScheme.outerSpace: l(context).settings_colorScheme_outerSpace,
      FlexScheme.blueWhale: l(context).settings_colorScheme_blueWhale,
      FlexScheme.sanJuanBlue: l(context).settings_colorScheme_sanJuanBlue,
      FlexScheme.rosewood: l(context).settings_colorScheme_rosewood,
      FlexScheme.blumineBlue: l(context).settings_colorScheme_blumineBlue,
      FlexScheme.flutterDash: l(context).settings_colorScheme_flutterDash,
    };

SelectionMenu<FlexScheme> themeSelect(BuildContext context) => SelectionMenu(
      l(context).settings_colorScheme,
      themeNameMap(context)
          .keys
          .map((theme) => SelectionMenuItem(
                value: theme,
                title: themeNameMap(context)[theme]!,
                icon: Symbols.brightness_1_rounded,
                iconColor: FlexColor.schemesWithCustom[theme]!.light.primary,
              ))
          .toList(),
    );

const SelectionMenu<PostImagePosition> postLayoutSelect = SelectionMenu(
  'Post Image Position',
  [
    SelectionMenuItem(
      value: PostImagePosition.auto,
      title: 'Auto',
      icon: Symbols.auto_mode_rounded,
    ),
    SelectionMenuItem(
      value: PostImagePosition.top,
      title: 'Top',
      icon: Symbols.smartphone_rounded,
    ),
    SelectionMenuItem(
      value: PostImagePosition.right,
      title: 'Right',
      icon: Symbols.tablet_rounded,
    ),
  ],
);

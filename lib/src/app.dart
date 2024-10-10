import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:interstellar/src/screens/explore/explore_screen.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/screens/profile/notification/notification_badge.dart';
import 'package:interstellar/src/screens/profile/notification/notification_count_controller.dart';
import 'package:interstellar/src/screens/profile/profile_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/utils/variables.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

import 'screens/settings/settings_controller.dart';
import 'screens/settings/settings_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _navIndex = 0;

  void _changeNav(int newIndex) {
    setState(() {
      _navIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watch<SettingsController>();

    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        final dynamicLightColorScheme =
            settingsController.useDynamicColor ? lightColorScheme : null;
        final dynamicDarkColorScheme =
            settingsController.useDynamicColor ? darkColorScheme : null;

        addThemeData(ThemeData theme) => theme.copyWith(
              iconTheme: theme.iconTheme.copyWith(fill: 1),
            );

        return ChangeNotifierProxyProvider<SettingsController,
            NotificationCountController>(
          create: (_) => NotificationCountController(),
          update: (_, settingsController, notificationCountController) =>
              notificationCountController!
                ..updateSettingsController(settingsController),
          child: MaterialApp(
            restorationScopeId: 'app',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (BuildContext context) => l(context).interstellar,
            theme: addThemeData(FlexThemeData.light(
              colorScheme: dynamicLightColorScheme,
              scheme: dynamicLightColorScheme != null
                  ? null
                  : settingsController.colorScheme,
              surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
              blendLevel: 13,
              useMaterial3: true,
            )),
            darkTheme: addThemeData(FlexThemeData.dark(
              colorScheme: dynamicDarkColorScheme,
              scheme: dynamicDarkColorScheme != null
                  ? null
                  : settingsController.colorScheme,
              surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
              blendLevel: 13,
              useMaterial3: true,
              darkIsTrueBlack: settingsController.enableTrueBlack,
            )),
            themeMode: settingsController.themeMode,
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: OrientationBuilder(
              builder: (context, orientation) {
                return Scaffold(
                  bottomNavigationBar: orientation == Orientation.portrait
                      ? NavigationBar(
                          height: 56,
                          labelBehavior:
                              NavigationDestinationLabelBehavior.alwaysHide,
                          destinations: [
                            NavigationDestination(
                              label: l(context).feed,
                              icon: const Icon(Symbols.home_rounded, fill: 0),
                              selectedIcon:
                                  const Icon(Symbols.home_rounded, fill: 1),
                            ),
                            NavigationDestination(
                              label: l(context).explore,
                              icon:
                                  const Icon(Symbols.explore_rounded, fill: 0),
                              selectedIcon:
                                  const Icon(Symbols.explore_rounded, fill: 1),
                            ),
                            NavigationDestination(
                              label: l(context).profile,
                              icon: Wrapper(
                                shouldWrap: context
                                    .watch<SettingsController>()
                                    .isLoggedIn,
                                parentBuilder: (child) =>
                                    NotificationBadge(child: child),
                                child:
                                    const Icon(Symbols.person_rounded, fill: 0),
                              ),
                              selectedIcon: Wrapper(
                                shouldWrap: context
                                    .watch<SettingsController>()
                                    .isLoggedIn,
                                parentBuilder: (child) =>
                                    NotificationBadge(child: child),
                                child:
                                    const Icon(Symbols.person_rounded, fill: 1),
                              ),
                            ),
                            NavigationDestination(
                              label: l(context).settings,
                              icon:
                                  const Icon(Symbols.settings_rounded, fill: 0),
                              selectedIcon:
                                  const Icon(Symbols.settings_rounded, fill: 1),
                            ),
                          ],
                          selectedIndex: _navIndex,
                          onDestinationSelected: _changeNav,
                        )
                      : null,
                  body: Row(children: [
                    if (orientation == Orientation.landscape)
                      NavigationRail(
                        selectedIndex: _navIndex,
                        onDestinationSelected: _changeNav,
                        labelType: NavigationRailLabelType.all,
                        destinations: [
                          NavigationRailDestination(
                              label: Text(l(context).feed),
                              icon: const Icon(Symbols.feed_rounded, fill: 0),
                              selectedIcon: const Icon(Symbols.feed_rounded)),
                          NavigationRailDestination(
                              label: Text(l(context).explore),
                              icon:
                                  const Icon(Symbols.explore_rounded, fill: 0),
                              selectedIcon:
                                  const Icon(Symbols.explore_rounded)),
                          NavigationRailDestination(
                            label: Text(l(context).profile),
                            icon: Wrapper(
                              shouldWrap: context
                                  .watch<SettingsController>()
                                  .isLoggedIn,
                              parentBuilder: (child) =>
                                  NotificationBadge(child: child),
                              child:
                                  const Icon(Symbols.person_rounded, fill: 0),
                            ),
                            selectedIcon: Wrapper(
                              shouldWrap: context
                                  .watch<SettingsController>()
                                  .isLoggedIn,
                              parentBuilder: (child) =>
                                  NotificationBadge(child: child),
                              child: const Icon(Symbols.person_rounded),
                            ),
                          ),
                          NavigationRailDestination(
                              label: Text(l(context).settings),
                              icon:
                                  const Icon(Symbols.settings_rounded, fill: 0),
                              selectedIcon:
                                  const Icon(Symbols.settings_rounded)),
                        ],
                      ),
                    if (orientation == Orientation.landscape)
                      const VerticalDivider(
                        thickness: 1,
                        width: 1,
                      ),
                    Expanded(
                        child: const [
                      FeedScreen(),
                      ExploreScreen(),
                      ProfileScreen(),
                      SettingsScreen(),
                    ][_navIndex]),
                  ]),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

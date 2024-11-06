import 'package:dynamic_color/dynamic_color.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:interstellar/src/controller/controller.dart';
import 'package:interstellar/src/screens/account/account_screen.dart';
import 'package:interstellar/src/screens/account/notification/notification_badge.dart';
import 'package:interstellar/src/screens/account/notification/notification_count_controller.dart';
import 'package:interstellar/src/screens/explore/explore_screen.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/screens/settings/settings_screen.dart';
import 'package:interstellar/src/utils/utils.dart';
import 'package:interstellar/src/utils/variables.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

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
    final appController = context.watch<AppController>();

    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        final dynamicLightColorScheme =
            appController.profile.colorScheme == FlexScheme.custom
                ? lightColorScheme
                : null;
        final dynamicDarkColorScheme =
            appController.profile.colorScheme == FlexScheme.custom
                ? darkColorScheme
                : null;

        return ChangeNotifierProxyProvider<AppController,
            NotificationCountController>(
          create: (_) => NotificationCountController(),
          update: (_, appController, notificationCountController) =>
              notificationCountController!..updateAppController(appController),
          child: MaterialApp(
            restorationScopeId: 'app',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (BuildContext context) => l(context).interstellar,
            theme: FlexThemeData.light(
              colorScheme: dynamicLightColorScheme,
              scheme: dynamicLightColorScheme != null
                  ? null
                  : appController.profile.colorScheme,
              surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
              blendLevel: 13,
              useMaterial3: true,
            ),
            darkTheme: FlexThemeData.dark(
              colorScheme: dynamicDarkColorScheme,
              scheme: dynamicDarkColorScheme != null
                  ? null
                  : appController.profile.colorScheme,
              surfaceMode: FlexSurfaceMode.highSurfaceLowScaffold,
              blendLevel: 13,
              useMaterial3: true,
              darkIsTrueBlack: appController.profile.enableTrueBlack,
            ),
            themeMode: appController.profile.themeMode,
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
                              icon: const Icon(Symbols.home_rounded),
                              selectedIcon:
                                  const Icon(Symbols.home_rounded, fill: 1),
                            ),
                            NavigationDestination(
                              label: l(context).explore,
                              icon: const Icon(Symbols.explore_rounded),
                              selectedIcon:
                                  const Icon(Symbols.explore_rounded, fill: 1),
                            ),
                            NavigationDestination(
                              label: l(context).account,
                              icon: Wrapper(
                                shouldWrap:
                                    context.watch<AppController>().isLoggedIn,
                                parentBuilder: (child) =>
                                    NotificationBadge(child: child),
                                child: const Icon(Symbols.person_rounded),
                              ),
                              selectedIcon: Wrapper(
                                shouldWrap:
                                    context.watch<AppController>().isLoggedIn,
                                parentBuilder: (child) =>
                                    NotificationBadge(child: child),
                                child:
                                    const Icon(Symbols.person_rounded, fill: 1),
                              ),
                            ),
                            NavigationDestination(
                              label: l(context).settings,
                              icon: const Icon(Symbols.settings_rounded),
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
                              icon: const Icon(Symbols.feed_rounded),
                              selectedIcon:
                                  const Icon(Symbols.feed_rounded, fill: 1)),
                          NavigationRailDestination(
                              label: Text(l(context).explore),
                              icon: const Icon(Symbols.explore_rounded),
                              selectedIcon:
                                  const Icon(Symbols.explore_rounded, fill: 1)),
                          NavigationRailDestination(
                            label: Text(l(context).account),
                            icon: Wrapper(
                              shouldWrap:
                                  context.watch<AppController>().isLoggedIn,
                              parentBuilder: (child) =>
                                  NotificationBadge(child: child),
                              child: const Icon(Symbols.person_rounded),
                            ),
                            selectedIcon: Wrapper(
                              shouldWrap:
                                  context.watch<AppController>().isLoggedIn,
                              parentBuilder: (child) =>
                                  NotificationBadge(child: child),
                              child:
                                  const Icon(Symbols.person_rounded, fill: 1),
                            ),
                          ),
                          NavigationRailDestination(
                            label: Text(l(context).settings),
                            icon: const Icon(Symbols.settings_rounded),
                            selectedIcon:
                                const Icon(Symbols.settings_rounded, fill: 1),
                          ),
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
                      AccountScreen(),
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

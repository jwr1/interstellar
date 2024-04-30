import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:interstellar/src/screens/explore/explore_screen.dart';
import 'package:interstellar/src/screens/feed/feed_screen.dart';
import 'package:interstellar/src/screens/profile/notification/notification_badge.dart';
import 'package:interstellar/src/screens/profile/notification/notification_count_controller.dart';
import 'package:interstellar/src/screens/profile/profile_screen.dart';
import 'package:interstellar/src/utils/variables.dart';
import 'package:interstellar/src/widgets/wrapper.dart';
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
      builder: (lightColourScheme, darkColourScheme) {
        return ChangeNotifierProxyProvider<SettingsController,
            NotificationCountController>(
          create: (_) => NotificationCountController(),
          update: (_, settingsController, notificationCountController) =>
              notificationCountController!
                ..updateSettingsController(settingsController),
          child: MaterialApp(
            restorationScopeId: 'app',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: ThemeData(
              colorScheme: settingsController.useDynamicColor &&
                      lightColourScheme != null
                  ? lightColourScheme
                  : settingsController.theme.lightMode,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme:
                  settingsController.useDynamicColor && darkColourScheme != null
                      ? darkColourScheme
                      : settingsController.theme.darkMode,
              useMaterial3: true,
            ),
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
                            const NavigationDestination(
                                label: 'Feed',
                                icon: Icon(Icons.feed_outlined),
                                selectedIcon: Icon(Icons.feed)),
                            const NavigationDestination(
                                label: 'Explore',
                                icon: Icon(Icons.explore_outlined),
                                selectedIcon: Icon(Icons.explore)),
                            NavigationDestination(
                              label: 'Profile',
                              icon: Wrapper(
                                shouldWrap: context
                                    .watch<SettingsController>()
                                    .isLoggedIn,
                                parentBuilder: (child) =>
                                    NotificationBadge(child: child),
                                child: const Icon(Icons.person_outlined),
                              ),
                              selectedIcon: Wrapper(
                                shouldWrap: context
                                    .watch<SettingsController>()
                                    .isLoggedIn,
                                parentBuilder: (child) =>
                                    NotificationBadge(child: child),
                                child: const Icon(Icons.person),
                              ),
                            ),
                            const NavigationDestination(
                                label: 'Settings',
                                icon: Icon(Icons.settings_outlined),
                                selectedIcon: Icon(Icons.settings)),
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
                          const NavigationRailDestination(
                              label: Text('Feed'),
                              icon: Icon(Icons.feed_outlined),
                              selectedIcon: Icon(Icons.feed)),
                          const NavigationRailDestination(
                              label: Text('Explore'),
                              icon: Icon(Icons.explore_outlined),
                              selectedIcon: Icon(Icons.explore)),
                          NavigationRailDestination(
                            label: const Text('Profile'),
                            icon: Wrapper(
                              shouldWrap: context
                                  .watch<SettingsController>()
                                  .isLoggedIn,
                              parentBuilder: (child) =>
                                  NotificationBadge(child: child),
                              child: const Icon(Icons.person_outlined),
                            ),
                            selectedIcon: Wrapper(
                              shouldWrap: context
                                  .watch<SettingsController>()
                                  .isLoggedIn,
                              parentBuilder: (child) =>
                                  NotificationBadge(child: child),
                              child: const Icon(Icons.person),
                            ),
                          ),
                          const NavigationRailDestination(
                              label: Text('Settings'),
                              icon: Icon(Icons.settings_outlined),
                              selectedIcon: Icon(Icons.settings)),
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

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:interstellar/src/screens/explore/explore_screen.dart';
import 'package:interstellar/src/screens/explore/magazines_screen.dart';
import 'package:interstellar/src/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';

import 'screens/entries/entries_screen.dart';
import 'screens/settings/settings_controller.dart';
import 'screens/settings/settings_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return ChangeNotifierProvider.value(
          value: widget.settingsController,
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
            theme: ThemeData(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: widget.settingsController.themeMode,
            home: Scaffold(
              bottomNavigationBar: NavigationBar(
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.feed), label: 'Feed'),
                  NavigationDestination(
                      icon: Icon(Icons.explore), label: 'Explore'),
                  NavigationDestination(
                      icon: Icon(Icons.person), label: 'Profile'),
                  NavigationDestination(
                      icon: Icon(Icons.settings), label: 'Settings'),
                ],
                selectedIndex: navIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    navIndex = index;
                  });
                },
              ),
              body: [
                const EntriesScreen(),
                const ExploreScreen(),
                const ProfileScreen(),
                SettingsScreen(controller: widget.settingsController)
              ][navIndex],
            ),
          ),
        );
      },
    );
  }
}
